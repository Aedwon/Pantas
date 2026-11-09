# Checks content/lesson-prerequisites.json and content/question-gap-tags.json
# against the rules the content export enforces on the roadmap lineage
# (R1-R2 roadmap plan, section 1.4), plus the CET rule that a required link
# never leaves an exam the dependent lesson belongs to.
# Usage: ruby tools/content_rewrite/check_cet_links.rb   (exit 1 on any error)
require 'json'
require 'yaml'

root = File.expand_path('../..', __dir__)
Dir.chdir(root)

lessons = {}   # id => path
Dir.glob('content/lessons/**/*.md').each do |f|
  m = File.read(f).match(/^_id:\s*"?([^"\n]+)"?/)
  lessons[m[1].strip] = f if m
end

exams = {}     # lesson id => exam list
questions = {} # question id => {lesson:, choices: [[text, correct]]}
lessons.each do |id, path|
  q = path.sub('content/lessons/', 'content/questions/').sub(/\.md\z/, '.yaml')
  next unless File.exist?(q)
  d = YAML.load_file(q)
  exams[id] = (d['meta'] || {})['exams'] || []
  (d['questions'] || []).each do |x|
    questions[x['id']] = { lesson: id, choices: (x['choices'] || []).map { |c| [c['text'].to_s, c['correct'] == true] } }
  end
end

errors = []
p = JSON.parse(File.read('content/lesson-prerequisites.json'))
errors << 'prerequisites: bad version' unless p['version'] == 1
links = p['lessons'] || {}
edges = Hash.new { |h, k| h[k] = [] }
links.each do |lesson, list|
  errors << "unknown lesson #{lesson}" unless lessons[lesson]
  seen = {}
  list.each do |l|
    t = l['lesson']
    errors << "#{lesson}: unknown target #{t}" unless lessons[t]
    errors << "#{lesson}: self link" if t == lesson
    errors << "#{lesson}: duplicate link to #{t}" if seen[t]
    seen[t] = true
    errors << "#{lesson} -> #{t}: bad strength #{l['strength']}" unless %w[required helpful].include?(l['strength'])
    errors << "#{lesson} -> #{t}: empty reason" if l['reason'].to_s.strip.empty?
    edges[lesson] << t
    next unless l['strength'] == 'required'
    missing = (exams[lesson] || []) - (exams[t] || [])
    errors << "#{lesson} -> #{t}: required link leaves exams #{missing.join(',')}" unless missing.empty?
  end
end

# Cycle check over all links.
state = {}
cycle = nil
visit = lambda do |n, stack|
  return if cycle
  state[n] = :open
  edges[n].each do |m|
    if state[m] == :open then cycle = (stack + [n, m]).join(' -> ')
    elsif state[m].nil? then visit.call(m, stack + [n])
    end
  end
  state[n] = :done
end
edges.keys.each { |n| visit.call(n, []) unless state[n] }
errors << "cycle: #{cycle}" if cycle

g = JSON.parse(File.read('content/question-gap-tags.json'))
errors << 'gap tags: bad version' unless g['version'] == 1
(g['questions'] || {}).each do |qid, tags|
  q = questions[qid]
  unless q
    errors << "gap tag: unknown question #{qid}"
    next
  end
  tags.each do |text, target|
    matches = q[:choices].select { |c| c[0].strip == text.strip }
    errors << "#{qid}: tag text matches #{matches.size} choices: #{text}" unless matches.size == 1
    errors << "#{qid}: tag on the correct choice" if matches.size == 1 && matches[0][1]
    errors << "#{qid}: unknown tag lesson #{target}" unless lessons[target]
    own = (links[q[:lesson]] || []).map { |l| l['lesson'] }
    errors << "#{qid}: tag lesson #{target} is not a link target of #{q[:lesson]}" unless own.include?(target)
  end
end

counts = Hash.new(0)
links.each_value { |list| list.each { |l| counts[l['strength']] += 1 } }
puts "lessons with links: #{links.size}, required: #{counts['required']}, helpful: #{counts['helpful']}, tagged questions: #{(g['questions'] || {}).size}"
errors.each { |e| puts "ERROR #{e}" }
exit(errors.empty? ? 0 : 1)
