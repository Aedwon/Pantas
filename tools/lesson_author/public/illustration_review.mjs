const FILTERS = Object.freeze(['pending', 'changes-requested', 'approved', 'missing']);
const FILTER_LABELS = Object.freeze({
  pending: 'Pending',
  'changes-requested': 'Needs changes',
  approved: 'Approved',
  missing: 'Missing',
});

export function effectiveReviewStatus(item) {
  if (!item || !item.digest || item.status === 'missing') return 'missing';
  if (item.stale) return 'pending';
  if (item.status === 'approved' || item.status === 'changes-requested') {
    return item.status;
  }
  return 'pending';
}

export function filterReviewItems(items, filter) {
  const normalized = filter === 'needs-changes' ? 'changes-requested' : filter;
  if (!FILTERS.includes(normalized)) return [];
  return items.filter((item) => effectiveReviewStatus(item) === normalized);
}

export function queueNeighborKey(queue, currentKey, direction) {
  if (!Array.isArray(queue) || queue.length === 0 || (direction !== -1 && direction !== 1)) {
    return null;
  }
  const currentIndex = queue.findIndex((item) => item.key === currentKey);
  if (currentIndex === -1) {
    return direction === 1 ? queue[0].key : queue[queue.length - 1].key;
  }
  const neighbor = queue[currentIndex + direction];
  return neighbor?.key ?? null;
}

export function reviewProgress(items) {
  const progress = {
    total: items.length,
    pending: 0,
    changesRequested: 0,
    approved: 0,
    missing: 0,
    reviewed: 0,
  };
  for (const item of items) {
    const status = effectiveReviewStatus(item);
    if (status === 'changes-requested') progress.changesRequested += 1;
    else progress[status] += 1;
  }
  progress.reviewed = progress.approved + progress.changesRequested;
  return progress;
}

function initializeIllustrationReview() {
  const bridge = window.lessonAuthorBridge;
  if (!bridge) return;

  const byId = (id) => document.getElementById(id);
  const elements = {
    authorModeButton: byId('authorModeBtn'),
    reviewModeButton: byId('reviewModeBtn'),
    authorApp: byId('authorApp'),
    reviewApp: byId('illustrationReviewApp'),
    reviewQueue: byId('reviewQueue'),
    reviewProgress: byId('reviewProgressText'),
    reviewStatus: byId('reviewStatusLine'),
    reviewItemTitle: byId('reviewItemTitle'),
    reviewItemMeta: byId('reviewItemMeta'),
    reviewItemStatus: byId('reviewItemStatus'),
    reviewLessonMount: byId('reviewLessonMount'),
    reviewEvidence: byId('reviewEvidence'),
    reviewNotes: byId('reviewNotes'),
    approveButton: byId('reviewApproveBtn'),
    changesButton: byId('reviewChangesBtn'),
    previousButton: byId('reviewPrevBtn'),
    nextButton: byId('reviewNextBtn'),
    refreshButton: byId('refreshPreviewsBtn'),
    themeToggle: byId('reviewCodeThemeToggle'),
    themeLight: byId('reviewThemeLightBtn'),
    themeDark: byId('reviewThemeDarkBtn'),
    filterButtons: [...document.querySelectorAll('[data-review-filter]')],
  };

  if (Object.values(elements).some((value) => value == null)) return;

  const previewPane = elements.authorApp.querySelector('.preview');
  const authorWorkspace = elements.authorApp.querySelector('.workspace');
  if (!previewPane || !authorWorkspace) return;

  const state = {
    catalog: { items: [], summary: null },
    filter: 'pending',
    selectedKey: null,
    mode: 'author',
    codeTheme: 'light',
    loadingCatalog: false,
    saving: false,
    rebuilding: false,
  };

  function setMessage(message, kind = '') {
    elements.reviewStatus.textContent = message;
    elements.reviewStatus.className = `review-status ${kind}`;
  }

  function currentItem() {
    return state.catalog.items.find((item) => item.key === state.selectedKey) ?? null;
  }

  function currentQueue() {
    return filterReviewItems(state.catalog.items, state.filter);
  }

  function renderMode() {
    const reviewing = state.mode === 'review';
    elements.authorModeButton.setAttribute('aria-pressed', String(!reviewing));
    elements.reviewModeButton.setAttribute('aria-pressed', String(reviewing));
    elements.authorModeButton.classList.toggle('active', !reviewing);
    elements.reviewModeButton.classList.toggle('active', reviewing);
    elements.authorApp.hidden = reviewing;
    elements.reviewApp.hidden = !reviewing;
  }

  async function enterReviewMode() {
    state.mode = 'review';
    elements.reviewLessonMount.append(previewPane);
    renderMode();
    if (state.catalog.items.length === 0) {
      await loadCatalog({ preserveKey: state.selectedKey, keepOutsideFilter: false });
    } else {
      await ensureSelection({ keepOutsideFilter: true });
    }
  }

  function enterAuthorMode() {
    state.mode = 'author';
    authorWorkspace.append(previewPane);
    bridge.renderPreview();
    renderMode();
    const title = bridge.currentLessonTitle?.();
    if (title) document.title = `${title} — Pantas Lesson Author`;
  }

  async function fetchCatalog() {
    const response = await fetch('/api/illustrations', { cache: 'no-store' });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(payload.error ?? 'Could not load illustration review items.');
    if (!payload || !Array.isArray(payload.items)) throw new Error('Illustration review catalog is invalid.');
    return payload;
  }

  async function loadCatalog({ preserveKey = null, keepOutsideFilter = false } = {}) {
    if (state.loadingCatalog) return;
    state.loadingCatalog = true;
    renderControls();
    try {
      state.catalog = await fetchCatalog();
      const preservedExists = preserveKey && state.catalog.items.some((item) => item.key === preserveKey);
      state.selectedKey = preservedExists ? preserveKey : state.selectedKey;
      renderQueue();
      await ensureSelection({ keepOutsideFilter });
    } catch (error) {
      setMessage(String(error.message ?? error), 'error');
      renderEmptyDetails('Illustration review items could not be loaded.');
    } finally {
      state.loadingCatalog = false;
      renderControls();
    }
  }

  async function ensureSelection({ keepOutsideFilter = false } = {}) {
    const selected = currentItem();
    const queue = currentQueue();
    const selectedInQueue = selected && queue.some((item) => item.key === selected.key);
    if (selected && (keepOutsideFilter || selectedInQueue)) {
      await selectItem(selected.key, { scroll: false });
      return;
    }
    if (queue.length > 0) {
      await selectItem(queue[0].key, { scroll: false });
    } else {
      state.selectedKey = null;
      renderQueue();
      renderEmptyDetails(`No ${FILTER_LABELS[state.filter].toLowerCase()} illustrations.`);
    }
  }

  function renderQueue() {
    const progress = reviewProgress(state.catalog.items);
    elements.reviewProgress.textContent =
      `${progress.reviewed} of ${progress.total} reviewed · ${progress.approved} approved · `
      + `${progress.changesRequested} need changes · ${progress.missing} missing`;

    for (const button of elements.filterButtons) {
      const filter = button.dataset.reviewFilter;
      const count = filterReviewItems(state.catalog.items, filter).length;
      button.querySelector('[data-filter-count]').textContent = String(count);
      const active = filter === state.filter;
      button.classList.toggle('active', active);
      button.setAttribute('aria-pressed', String(active));
    }

    const queue = currentQueue();
    elements.reviewQueue.replaceChildren();
    if (queue.length === 0) {
      const empty = document.createElement('p');
      empty.className = 'review-queue-empty';
      empty.textContent = `No ${FILTER_LABELS[state.filter].toLowerCase()} illustrations.`;
      elements.reviewQueue.append(empty);
    }

    for (const item of queue) {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'review-queue-item';
      button.dataset.key = item.key;
      button.setAttribute('aria-current', item.key === state.selectedKey ? 'true' : 'false');
      if (item.key === state.selectedKey) button.classList.add('current');

      const status = document.createElement('span');
      status.className = `review-queue-status status-${effectiveReviewStatus(item)}`;
      status.textContent = FILTER_LABELS[effectiveReviewStatus(item)];
      const lesson = document.createElement('strong');
      lesson.textContent = humanize(item.lesson);
      const topic = document.createElement('span');
      topic.className = 'review-queue-topic';
      topic.textContent = humanize(item.topic);
      button.append(status, lesson, topic);
      button.addEventListener('click', () => selectItem(item.key));
      elements.reviewQueue.append(button);
    }
    renderControls();
  }

  async function selectItem(key, { scroll = true } = {}) {
    const item = state.catalog.items.find((candidate) => candidate.key === key);
    if (!item) return;
    state.selectedKey = key;
    state.codeTheme = 'light';
    renderQueue();
    renderDetails(item);
    setMessage('Loading lesson…');
    try {
      await bridge.selectLessonById(item.lessonId);
      renderIllustrationInLesson(item, { scroll });
      setMessage(item.stale ? 'The saved review is stale because the preview changed.' : '');
    } catch (error) {
      setMessage(`Could not open the associated lesson: ${String(error.message ?? error)}`, 'error');
    }
  }

  function renderDetails(item) {
    elements.reviewItemTitle.textContent = humanize(item.lesson);
    elements.reviewItemMeta.textContent = `${humanize(item.subject)} · ${humanize(item.topic)} · illustration ${item.seq}`;
    const status = effectiveReviewStatus(item);
    elements.reviewItemStatus.textContent = FILTER_LABELS[status];
    elements.reviewItemStatus.className = `review-item-status status-${status}`;
    elements.reviewNotes.value = item.notes ?? '';
    renderEvidence(item);
    renderControls();
  }

  function renderEmptyDetails(message) {
    elements.reviewItemTitle.textContent = 'Illustration review';
    elements.reviewItemMeta.textContent = '';
    elements.reviewItemStatus.textContent = '';
    elements.reviewItemStatus.className = 'review-item-status';
    elements.reviewNotes.value = '';
    elements.reviewEvidence.innerHTML = `<p class="review-empty">${escapeHtml(message)}</p>`;
    bridge.renderPreview();
    renderControls();
  }

  function renderEvidence(item) {
    const evidence = item.evidence ?? {};
    const sections = [];
    if (evidence.brief) {
      sections.push(`<div class="evidence-section"><h3>Frozen brief</h3><p>${escapeHtml(evidence.brief)}</p></div>`);
    }
    if (item.strategy === 'code') {
      const references = Array.isArray(evidence.references) ? evidence.references : [];
      sections.push(
        `<div class="evidence-section"><h3>Factual references</h3>${references.length
          ? `<ul>${references.map((reference) => `<li>${safeExternalLink(reference.url, reference.title ?? reference.url)}${reference.publisher ? ` <span>${escapeHtml(reference.publisher)}</span>` : ''}</li>`).join('')}</ul>`
          : '<p>No factual references are listed.</p>'}</div>`,
      );
    } else if (item.strategy === 'open') {
      const commons = evidence.commons ?? {};
      sections.push(`<div class="evidence-section"><h3>Commons source and credit</h3>${definitionList([
        ['Creator', commons.creator],
        ['Source page', safeExternalLink(commons.sourcePage, commons.sourcePage)],
        ['Direct file', safeExternalLink(commons.directUrl, commons.directUrl)],
        ['License', commons.license],
        ['Credit', commons.credit],
        ['Local target', commons.target],
        ['Declared SHA-256', commons.declaredSha256],
      ])}</div>`);
    } else if (item.strategy === 'founder') {
      sections.push(`<div class="evidence-section"><h3>Ownership</h3><p>${escapeHtml(evidence.ownership ?? 'Pantas — all rights reserved')}</p></div>`);
    }
    if (item.stale) {
      sections.push('<p class="review-notice"><strong>Preview changed.</strong> The earlier decision no longer matches the current digest. The saved note is kept for reference.</p>');
    }
    if (item.missingReason) {
      sections.push(`<p class="review-notice missing"><strong>Missing.</strong> ${escapeHtml(item.missingReason)}</p>`);
    }
    elements.reviewEvidence.innerHTML = sections.join('');
  }

  function renderControls() {
    const item = currentItem();
    const missing = !item || effectiveReviewStatus(item) === 'missing';
    const busy = state.saving || state.rebuilding || state.loadingCatalog;
    elements.approveButton.disabled = missing || busy;
    elements.changesButton.disabled = missing || busy;
    elements.reviewNotes.disabled = missing || busy;
    elements.refreshButton.disabled = state.rebuilding || state.saving;
    elements.refreshButton.textContent = state.rebuilding ? 'Refreshing previews…' : 'Refresh previews';

    const queue = currentQueue();
    elements.previousButton.disabled = busy || !queueNeighborKey(queue, state.selectedKey, -1);
    elements.nextButton.disabled = busy || !queueNeighborKey(queue, state.selectedKey, 1);

    const code = item?.strategy === 'code' && item.digest;
    elements.themeToggle.hidden = !code;
    elements.reviewLessonMount.dataset.codeTheme = state.codeTheme;
    elements.themeLight.setAttribute('aria-pressed', String(state.codeTheme === 'light'));
    elements.themeDark.setAttribute('aria-pressed', String(state.codeTheme === 'dark'));
  }

  function renderIllustrationInLesson(item, { scroll }) {
    bridge.renderPreview();
    const previewBody = bridge.previewBody();
    const marker = findIllustrationMarker(previewBody, item.key);
    const context = buildIllustrationContext(item);
    if (marker) {
      marker.parentNode.insertBefore(context, marker.nextSibling);
    } else {
      const missingMarker = document.createElement('p');
      missingMarker.className = 'review-notice missing';
      missingMarker.textContent = 'This illustration marker was not found in the rendered lesson preview.';
      context.prepend(missingMarker);
      previewBody.prepend(context);
    }
    renderControls();
    if (scroll) context.scrollIntoView({ block: 'center', behavior: 'smooth' });
  }

  function buildIllustrationContext(item) {
    const container = document.createElement('section');
    container.className = 'lesson-illustration-context';
    container.dataset.strategy = item.strategy;
    container.dataset.illustrationKey = item.key;
    container.setAttribute('aria-label', `Illustration review preview for ${item.key}`);

    if (!item.digest) {
      const missing = document.createElement('div');
      missing.className = 'lesson-illustration-missing';
      missing.innerHTML = `<strong>Illustration missing</strong><span>${escapeHtml(item.missingReason ?? 'No local preview is available.')}</span>`;
      container.append(missing);
      return container;
    }

    const pair = document.createElement('div');
    pair.className = 'review-preview-pair';
    for (const theme of ['light', 'dark']) {
      const surface = document.createElement('figure');
      surface.className = `review-preview-frame theme-${theme}`;
      surface.dataset.theme = theme;
      const image = document.createElement('img');
      image.src = previewUrl(item, theme);
      image.alt = `${theme === 'light' ? 'Light' : 'Dark'} lesson preview for ${humanize(item.lesson)}`;
      image.loading = 'eager';
      const caption = document.createElement('figcaption');
      caption.textContent = `${theme === 'light' ? 'Light' : 'Dark'} lesson background`;
      surface.append(image, caption);
      pair.append(surface);
    }
    container.append(pair);
    return container;
  }

  function previewUrl(item, theme) {
    const query = new URLSearchParams({ key: item.key, theme });
    return `/api/illustration-preview?${query}`;
  }

  function findIllustrationMarker(root, key) {
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_COMMENT);
    let node = walker.nextNode();
    while (node) {
      const text = node.nodeValue ?? '';
      if (text.includes(key) || text.includes('illustrationKey')) {
        const open = text.indexOf('{');
        const close = text.lastIndexOf('}');
        if (open !== -1 && close > open) {
          try {
            const payload = JSON.parse(text.slice(open, close + 1));
            if (payload.illustrationKey === key) return node;
          } catch {
            // Ignore unrelated HTML comments and keep looking.
          }
        }
      }
      node = walker.nextNode();
    }
    return null;
  }

  async function saveDecision(status) {
    const item = currentItem();
    if (!item || !item.digest || effectiveReviewStatus(item) === 'missing') return;
    state.saving = true;
    renderControls();
    setMessage('Saving review…');
    try {
      const response = await fetch('/api/illustration-review', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          key: item.key,
          status,
          notes: elements.reviewNotes.value,
          observedDigest: item.digest,
        }),
      });
      const payload = await response.json().catch(() => ({}));
      if (response.status === 409) {
        await loadCatalog({ preserveKey: item.key, keepOutsideFilter: true });
        setMessage('Preview changed before your decision was saved. Review the current preview and submit again.', 'error');
        return;
      }
      if (!response.ok) throw new Error(payload.error ?? 'Could not save illustration review.');
      await loadCatalog({ preserveKey: item.key, keepOutsideFilter: true });
      setMessage(status === 'approved' ? 'Approval saved for the current preview.' : 'Needs changes saved for the current preview.', 'saved');
    } catch (error) {
      setMessage(String(error.message ?? error), 'error');
    } finally {
      state.saving = false;
      renderControls();
    }
  }

  async function refreshPreviews() {
    if (state.rebuilding) return;
    const selectedKey = state.selectedKey;
    state.rebuilding = true;
    renderControls();
    setMessage('Rebuilding Flutter previews…');
    try {
      const response = await fetch('/api/illustration-previews/rebuild', { method: 'POST' });
      const payload = await response.json().catch(() => ({}));
      if (!response.ok) throw new Error(payload.error ?? 'Preview rebuild failed.');
      await loadCatalog({ preserveKey: selectedKey, keepOutsideFilter: true });
      setMessage('Previews refreshed. Review status reflects the current digests.', 'saved');
    } catch (error) {
      setMessage(String(error.message ?? error), 'error');
    } finally {
      state.rebuilding = false;
      renderControls();
    }
  }

  async function moveQueue(direction) {
    const key = queueNeighborKey(currentQueue(), state.selectedKey, direction);
    if (key) await selectItem(key);
  }

  elements.authorModeButton.addEventListener('click', enterAuthorMode);
  elements.reviewModeButton.addEventListener('click', enterReviewMode);
  elements.approveButton.addEventListener('click', () => saveDecision('approved'));
  elements.changesButton.addEventListener('click', () => saveDecision('changes-requested'));
  elements.previousButton.addEventListener('click', () => moveQueue(-1));
  elements.nextButton.addEventListener('click', () => moveQueue(1));
  elements.refreshButton.addEventListener('click', refreshPreviews);
  elements.themeLight.addEventListener('click', () => {
    state.codeTheme = 'light';
    renderControls();
  });
  elements.themeDark.addEventListener('click', () => {
    state.codeTheme = 'dark';
    renderControls();
  });
  for (const button of elements.filterButtons) {
    button.addEventListener('click', async () => {
      state.filter = button.dataset.reviewFilter;
      state.selectedKey = null;
      renderQueue();
      await ensureSelection({ keepOutsideFilter: false });
    });
  }

  renderMode();
  renderControls();
}

function humanize(value) {
  return String(value ?? '')
    .replace(/[-_]+/g, ' ')
    .replace(/\b\w/g, (character) => character.toUpperCase());
}

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"']/g, (character) => ({
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
  })[character]);
}

function safeExternalLink(url, label) {
  if (typeof url !== 'string' || !/^https:\/\//.test(url)) return escapeHtml(label ?? url ?? '');
  return `<a href="${escapeHtml(url)}" target="_blank" rel="noreferrer">${escapeHtml(label ?? url)}</a>`;
}

function definitionList(rows) {
  return `<dl>${rows
    .filter(([, value]) => value != null && value !== '')
    .map(([label, value]) => `<div><dt>${escapeHtml(label)}</dt><dd>${String(value).startsWith('<a ') ? value : escapeHtml(value)}</dd></div>`)
    .join('')}</dl>`;
}

if (typeof window !== 'undefined' && typeof document !== 'undefined') {
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeIllustrationReview, { once: true });
  } else {
    initializeIllustrationReview();
  }
}
