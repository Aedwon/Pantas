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

function installReviewPolish() {
  if (document.getElementById('illustrationReviewPolishStyles')) return;

  const reviewApp = document.getElementById('illustrationReviewApp');
  const reviewQueue = document.getElementById('reviewQueue');
  const reviewProgress = document.getElementById('reviewProgressText');
  const reviewItemTitle = document.getElementById('reviewItemTitle');
  const reviewItemMeta = document.getElementById('reviewItemMeta');
  const reviewLessonMount = document.getElementById('reviewLessonMount');
  const reviewPrev = document.getElementById('reviewPrevBtn');
  const reviewNext = document.getElementById('reviewNextBtn');
  const reviewHead = reviewApp?.querySelector('.review-item-head');
  const header = document.querySelector('header');
  const headerTitle = header?.querySelector('h1');
  const titleNode = document.querySelector('title');
  if (!reviewApp || !reviewQueue || !reviewProgress || !reviewItemTitle || !reviewItemMeta
      || !reviewLessonMount || !reviewPrev || !reviewNext || !reviewHead || !header || !headerTitle) {
    return;
  }

  const style = document.createElement('style');
  style.id = 'illustrationReviewPolishStyles';
  style.textContent = `
    #authorApp[hidden] {
      display: none !important;
    }

    body.illustration-review-mode header {
      min-height: 50px;
      gap: 12px;
      flex-wrap: nowrap;
    }
    body.illustration-review-mode header .selectors,
    body.illustration-review-mode header .progress {
      display: none;
    }
    .review-header-context,
    .review-header-summary {
      display: none;
      min-width: 0;
      font-size: 12px;
      color: rgba(244, 241, 232, 0.8);
    }
    body.illustration-review-mode .review-header-context,
    body.illustration-review-mode .review-header-summary {
      display: block;
    }
    body.illustration-review-mode .review-header-context {
      flex: 1;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    body.illustration-review-mode .review-header-summary {
      margin-left: auto;
      white-space: nowrap;
      font-variant-numeric: tabular-nums;
    }

    body.illustration-review-mode #illustrationReviewApp {
      display: grid;
      grid-template-columns: clamp(230px, 18vw, 280px) minmax(500px, 1fr) clamp(350px, 25vw, 410px);
      grid-template-rows: auto minmax(0, 1fr) auto;
      min-height: 0;
      overflow: hidden;
      background: var(--paper);
    }
    body.illustration-review-mode #illustrationReviewApp[hidden] { display: none; }
    body.illustration-review-mode .review-sidebar {
      grid-column: 1;
      grid-row: 1 / 4;
      border-right: 1px solid var(--line);
      min-width: 0;
    }
    body.illustration-review-mode .review-sidebar-head {
      padding: 14px 14px 11px;
    }
    body.illustration-review-mode .review-sidebar-head h2 {
      margin-bottom: 3px;
      font-size: 14px;
    }
    body.illustration-review-mode .review-sidebar-head p {
      line-height: 1.45;
    }
    body.illustration-review-mode .review-filters {
      position: sticky;
      top: 0;
      z-index: 1;
      background: var(--panel);
    }
    body.illustration-review-mode .review-filters button {
      padding: 8px 10px;
      min-width: 0;
    }
    body.illustration-review-mode .review-queue {
      padding: 6px 0 18px;
    }
    body.illustration-review-mode .review-queue-item {
      padding: 8px 12px;
      grid-template-columns: 64px minmax(0, 1fr);
      gap: 2px 7px;
      border-left: 3px solid transparent;
    }
    body.illustration-review-mode .review-queue-item.current {
      border-left-color: var(--board);
      background: var(--board-soft);
    }
    body.illustration-review-mode .review-queue-item strong {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    body.illustration-review-mode .review-queue-topic {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    body.illustration-review-mode .review-queue-status {
      line-height: 1.25;
    }

    body.illustration-review-mode .review-main,
    body.illustration-review-mode .review-content {
      display: contents;
    }
    body.illustration-review-mode .review-toolbar {
      grid-column: 2 / 4;
      grid-row: 1;
      min-height: 48px;
      padding: 8px 14px;
      border-bottom: 1px solid var(--line);
      background: var(--panel);
    }
    body.illustration-review-mode .review-toolbar #refreshPreviewsBtn {
      margin-left: auto;
      order: 2;
    }
    body.illustration-review-mode .review-status {
      order: 1;
      min-width: 0;
      flex: 1;
    }
    body.illustration-review-mode .review-lesson-column {
      grid-column: 2;
      grid-row: 2;
      min-width: 0;
      min-height: 0;
      border-right: 1px solid var(--line);
      background: var(--paper);
    }
    body.illustration-review-mode .review-item-head {
      padding: 12px 16px 11px;
      display: grid;
      grid-template-columns: minmax(0, 1fr) auto;
      gap: 8px 12px;
      align-items: end;
    }
    body.illustration-review-mode .review-item-head .review-head-row {
      grid-column: 1 / -1;
      min-width: 0;
    }
    body.illustration-review-mode .review-item-head h2 {
      margin-top: 2px;
      font-size: 19px;
    }
    body.illustration-review-mode .review-item-meta {
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    body.illustration-review-mode .review-code-theme-toggle:not([hidden]) {
      grid-column: 1;
      justify-self: start;
      padding-top: 0;
    }
    .review-context-toggle {
      grid-column: 2;
      justify-self: end;
      font: inherit;
      font-size: 12.5px;
      padding: 6px 10px;
      border: 1px solid var(--line);
      border-radius: 6px;
      background: var(--panel);
      color: var(--ink);
      cursor: pointer;
    }
    .review-context-toggle:hover { border-color: var(--board); color: var(--board); }
    .review-context-toggle:focus-visible { outline: 2px solid var(--board); outline-offset: 1px; }
    body.illustration-review-mode .review-lesson-mount {
      min-height: 0;
      overflow: hidden;
    }
    body.illustration-review-mode .review-lesson-mount > .preview {
      height: 100%;
      overflow: auto;
      padding: 24px 24px 40px;
    }
    body.illustration-review-mode .review-lesson-mount .preview-body {
      width: 100%;
      max-width: none;
      min-height: 100%;
      margin: 0 auto;
    }
    body.illustration-review-mode .review-lesson-mount:not(.show-lesson-context) .format-warning,
    body.illustration-review-mode .review-lesson-mount:not(.show-lesson-context) .preview-body > :not(.lesson-illustration-context) {
      display: none !important;
    }
    body.illustration-review-mode .lesson-illustration-context {
      margin: 0;
      scroll-margin: 24px 0;
    }
    body.illustration-review-mode .review-preview-pair {
      gap: 16px;
      align-items: stretch;
    }
    body.illustration-review-mode .review-preview-frame {
      min-width: 0;
      min-height: 280px;
      padding: 16px;
      display: flex;
      flex-direction: column;
      justify-content: center;
      border-radius: 8px;
    }
    body.illustration-review-mode .review-preview-frame img {
      width: 100%;
      max-height: calc(100vh - 270px);
      object-fit: contain;
    }
    body.illustration-review-mode .review-preview-frame figcaption {
      margin-top: 9px;
    }
    body.illustration-review-mode .lesson-illustration-missing {
      margin: 24px auto;
      max-width: 680px;
      padding: 24px;
      border: 1px solid #EAD9AE;
      border-radius: 8px;
      background: var(--amber-soft);
    }

    body.illustration-review-mode .review-inspector {
      grid-column: 3;
      grid-row: 2 / 4;
      min-width: 0;
      overflow-y: auto;
      padding: 18px 18px 24px;
      border-left: 0;
      background: var(--panel);
    }
    body.illustration-review-mode .review-inspector > h2 {
      position: sticky;
      top: -18px;
      z-index: 1;
      margin: -18px -18px 10px;
      padding: 14px 18px 10px;
      border-bottom: 1px solid var(--line);
      background: var(--panel);
    }
    body.illustration-review-mode .evidence-section {
      padding: 13px 0;
    }
    body.illustration-review-mode .evidence-section p,
    body.illustration-review-mode .evidence-section ul,
    body.illustration-review-mode .evidence-section dd {
      line-height: 1.5;
    }
    body.illustration-review-mode .review-controls {
      margin-top: 16px;
      padding-top: 16px;
    }
    body.illustration-review-mode .review-notes {
      min-height: 130px;
    }
    body.illustration-review-mode .review-decision-row button {
      min-height: 38px;
    }

    .review-bottom-nav {
      grid-column: 2;
      grid-row: 3;
      display: grid;
      grid-template-columns: auto minmax(0, 1fr) auto;
      gap: 10px;
      align-items: center;
      min-height: 52px;
      padding: 8px 14px;
      border-top: 1px solid var(--line);
      border-right: 1px solid var(--line);
      background: var(--panel);
    }
    .review-bottom-nav button {
      font: inherit;
      font-size: 13px;
      min-width: 92px;
      padding: 7px 12px;
      border: 1px solid var(--line);
      border-radius: 6px;
      background: var(--panel);
      color: var(--ink);
      cursor: pointer;
    }
    .review-bottom-nav button:hover:not(:disabled) { border-color: var(--board); color: var(--board); }
    .review-bottom-nav button:disabled { opacity: 0.45; cursor: not-allowed; }
    .review-bottom-nav button:focus-visible { outline: 2px solid var(--board); outline-offset: 1px; }
    .review-bottom-position {
      min-width: 0;
      text-align: center;
      color: var(--ink-soft);
      font-size: 12px;
      font-variant-numeric: tabular-nums;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    @media (max-width: 1320px) {
      body.illustration-review-mode #illustrationReviewApp {
        grid-template-columns: 220px minmax(430px, 1fr) 340px;
      }
      body.illustration-review-mode .review-code-theme-toggle:not([hidden]) { display: inline-flex; }
      body.illustration-review-mode #reviewLessonMount[data-code-theme="light"] .lesson-illustration-context[data-strategy="code"] .review-preview-frame[data-theme="dark"],
      body.illustration-review-mode #reviewLessonMount[data-code-theme="dark"] .lesson-illustration-context[data-strategy="code"] .review-preview-frame[data-theme="light"] {
        display: none;
      }
      body.illustration-review-mode .review-preview-pair { grid-template-columns: 1fr; }
      body.illustration-review-mode .review-preview-frame { min-height: 360px; }
    }

    @media (min-width: 1321px) {
      body.illustration-review-mode .review-code-theme-toggle:not([hidden]) { display: none; }
    }

    @media (max-width: 1040px) {
      body.illustration-review-mode #illustrationReviewApp {
        grid-template-columns: 210px minmax(0, 1fr);
        grid-template-rows: auto minmax(500px, 1fr) auto auto;
        overflow-y: auto;
      }
      body.illustration-review-mode .review-sidebar {
        grid-column: 1;
        grid-row: 1 / 5;
      }
      body.illustration-review-mode .review-toolbar {
        grid-column: 2;
        grid-row: 1;
      }
      body.illustration-review-mode .review-lesson-column {
        grid-column: 2;
        grid-row: 2;
        border-right: 0;
      }
      body.illustration-review-mode .review-inspector {
        grid-column: 2;
        grid-row: 3;
        max-height: none;
        overflow: visible;
        border-top: 1px solid var(--line);
      }
      .review-bottom-nav {
        grid-column: 2;
        grid-row: 4;
        position: sticky;
        bottom: 0;
        z-index: 2;
        border-right: 0;
      }
      body.illustration-review-mode .review-preview-frame img {
        max-height: 70vh;
      }
    }

    @media (max-width: 760px) {
      body.illustration-review-mode header {
        flex-wrap: wrap;
      }
      body.illustration-review-mode header .mode-switch {
        order: 0;
      }
      body.illustration-review-mode .review-header-context {
        order: 3;
        flex-basis: 100%;
      }
      body.illustration-review-mode .review-header-summary {
        display: none;
      }
      body.illustration-review-mode #illustrationReviewApp {
        display: flex;
        flex-direction: column;
        overflow-y: auto;
      }
      body.illustration-review-mode #illustrationReviewApp[hidden] { display: none; }
      body.illustration-review-mode .review-sidebar {
        flex: 0 0 auto;
        max-height: 34vh;
        border-right: 0;
        border-bottom: 1px solid var(--line);
      }
      body.illustration-review-mode .review-main {
        display: flex;
        flex-direction: column;
        min-height: 0;
      }
      body.illustration-review-mode .review-content {
        display: flex;
        flex-direction: column;
      }
      body.illustration-review-mode .review-toolbar {
        order: 0;
      }
      body.illustration-review-mode .review-lesson-column {
        min-height: 62vh;
      }
      body.illustration-review-mode .review-item-head {
        grid-template-columns: 1fr;
        align-items: start;
      }
      body.illustration-review-mode .review-code-theme-toggle:not([hidden]),
      .review-context-toggle {
        grid-column: 1;
        justify-self: start;
      }
      body.illustration-review-mode .review-lesson-mount > .preview {
        padding: 18px 14px 30px;
      }
      body.illustration-review-mode .review-preview-frame {
        min-height: 280px;
        padding: 12px;
      }
      body.illustration-review-mode .review-inspector {
        max-height: none;
        padding: 16px;
      }
      .review-bottom-nav {
        flex: 0 0 auto;
        position: sticky;
        bottom: 0;
        z-index: 3;
        border-right: 0;
      }
    }
  `;
  document.head.append(style);

  const headerContext = document.createElement('span');
  headerContext.className = 'review-header-context';
  headerContext.setAttribute('aria-live', 'polite');
  const headerSummary = document.createElement('span');
  headerSummary.className = 'review-header-summary';
  header.append(headerContext, headerSummary);

  const contextToggle = document.createElement('button');
  contextToggle.type = 'button';
  contextToggle.className = 'review-context-toggle';
  contextToggle.setAttribute('aria-pressed', 'false');
  contextToggle.textContent = 'Show lesson context';
  reviewHead.append(contextToggle);

  const bottomNav = document.createElement('div');
  bottomNav.className = 'review-bottom-nav';
  bottomNav.setAttribute('role', 'group');
  bottomNav.setAttribute('aria-label', 'Illustration review navigation');
  const bottomPosition = document.createElement('span');
  bottomPosition.className = 'review-bottom-position';
  bottomNav.append(reviewPrev, bottomPosition, reviewNext);
  reviewApp.append(bottomNav);

  function setLessonContextVisible(visible) {
    reviewLessonMount.classList.toggle('show-lesson-context', visible);
    contextToggle.setAttribute('aria-pressed', String(visible));
    contextToggle.textContent = visible ? 'Hide lesson context' : 'Show lesson context';
  }

  function updateHeaderContext() {
    const title = reviewItemTitle.textContent.trim();
    const meta = reviewItemMeta.textContent.trim();
    headerContext.textContent = [meta, title && title !== 'Illustration review' ? title : '']
      .filter(Boolean)
      .join(' · ');
  }

  function updateHeaderSummary() {
    headerSummary.textContent = reviewProgress.textContent.trim();
  }

  function updateQueuePosition() {
    const items = [...reviewQueue.querySelectorAll('.review-queue-item')];
    const index = items.findIndex((item) => item.getAttribute('aria-current') === 'true');
    const activeFilter = document.querySelector('[data-review-filter].active span:first-child')?.textContent?.trim();
    if (items.length === 0) {
      bottomPosition.textContent = activeFilter ? `No ${activeFilter.toLowerCase()} items` : 'No items in this queue';
      return;
    }
    bottomPosition.textContent = index >= 0
      ? `${index + 1} of ${items.length}${activeFilter ? ` · ${activeFilter}` : ''}`
      : `${items.length} ${activeFilter ? activeFilter.toLowerCase() : 'review'} items`;
  }

  function syncModeChrome() {
    const reviewing = !reviewApp.hidden;
    document.body.classList.toggle('illustration-review-mode', reviewing);
    headerTitle.innerHTML = reviewing ? 'Pantas <span>· Illustration Review</span>' : 'Pantas <span>· Lesson Author</span>';
    if (!reviewing) setLessonContextVisible(false);
    updateHeaderContext();
    updateHeaderSummary();
    updateQueuePosition();
  }

  function syncDocumentTitle() {
    if (reviewApp.hidden || !titleNode) return;
    const itemTitle = reviewItemTitle.textContent.trim();
    const desired = `${itemTitle && itemTitle !== 'Illustration review' ? itemTitle : 'Illustration Review'} — Pantas Illustration Review`;
    if (document.title !== desired) document.title = desired;
  }

  contextToggle.addEventListener('click', () => {
    setLessonContextVisible(!reviewLessonMount.classList.contains('show-lesson-context'));
  });

  new MutationObserver(() => {
    syncModeChrome();
    syncDocumentTitle();
  }).observe(reviewApp, { attributes: true, attributeFilter: ['hidden'] });
  new MutationObserver(() => {
    updateHeaderSummary();
  }).observe(reviewProgress, { childList: true, characterData: true, subtree: true });
  new MutationObserver(() => {
    setLessonContextVisible(false);
    updateHeaderContext();
    syncDocumentTitle();
  }).observe(reviewItemTitle, { childList: true, characterData: true, subtree: true });
  new MutationObserver(() => {
    updateHeaderContext();
  }).observe(reviewItemMeta, { childList: true, characterData: true, subtree: true });
  new MutationObserver(() => {
    updateQueuePosition();
  }).observe(reviewQueue, { childList: true, subtree: true, attributes: true, attributeFilter: ['aria-current', 'class'] });
  if (titleNode) {
    new MutationObserver(() => syncDocumentTitle()).observe(titleNode, { childList: true, characterData: true, subtree: true });
  }

  setLessonContextVisible(false);
  syncModeChrome();
}

if (typeof window !== 'undefined' && typeof document !== 'undefined') {
  const boot = () => {
    installReviewPolish();
    initializeIllustrationReview();
  };
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot, { once: true });
  } else {
    boot();
  }
}
