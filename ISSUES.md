# GyroCam Issue Tracker

<div align="center">
  <div style="margin: 20px 0;">
    <a href="https://github.com/fayaz12g/GyroCam/issues" target="_blank" style="padding: 8px 15px; background-color: #2ea44f; color: white; border-radius: 5px; text-decoration: none; margin-right: 10px;">View All Issues on GitHub</a>
    <a href="https://github.com/fayaz12g/GyroCam/issues/new/choose" target="_blank" style="padding: 8px 15px; background-color: #007bff; color: white; border-radius: 5px; text-decoration: none;">Create New Issue</a>
  </div>

  <div id="filters" style="margin: 20px 0;">
    <button class="filter-btn active" onclick="filterIssues('all')">All</button>
    <button class="filter-btn" onclick="filterIssues('open')">Open</button>
    <button class="filter-btn" onclick="filterIssues('closed')">Closed</button>
    <button class="filter-btn" onclick="filterIssues('bug')">Bugs</button>
    <button class="filter-btn" onclick="filterIssues('enhancement')">Enhancements</button>
  </div>
</div>

<div id="issues-container" style="margin: 20px 0;"></div>

<style>
  .issue-card {
    border: 1px solid #e1e4e8;
    border-radius: 6px;
    padding: 16px;
    margin-bottom: 16px;
    background-color: #f6f8fa;
  }
  .issue-title {
    font-size: 1.2em;
    margin-bottom: 8px;
  }
  .issue-meta {
    color: #586069;
    font-size: 0.9em;
    margin-bottom: 8px;
  }
  .label {
    display: inline-block;
    padding: 2px 5px;
    border-radius: 3px;
    font-size: 0.8em;
    margin-right: 5px;
  }
  .filter-btn {
    padding: 8px 16px;
    margin: 0 5px;
    border: 1px solid #e1e4e8;
    border-radius: 6px;
    cursor: pointer;
  }
  .filter-btn.active {
    background-color: #007bff;
    color: white;
    border-color: #007bff;
  }
</style>

<script>
  let allIssues = [];
  
  async function fetchIssues() {
    try {
      const response = await fetch('https://api.github.com/repos/fayaz12g/GyroCam/issues?state=all');
      let issues = await response.json();
      // Filter out pull requests
      issues = issues.filter(issue => !('pull_request' in issue));
      allIssues = issues;
      renderIssues(issues);
    } catch (error) {
      console.error('Error fetching issues:', error);
      document.getElementById('issues-container').innerHTML = 
        '<p>Error loading issues. Please <a href="https://github.com/fayaz12g/GyroCam/issues" target="_blank">view on GitHub</a>.</p>';
    }
  }

  function renderIssues(issues) {
    const container = document.getElementById('issues-container');
    container.innerHTML = issues.map(issue => `
      <div class="issue-card">
        <h3 class="issue-title">
          <a href="${issue.html_url}" target="_blank">${issue.title}</a>
          <span style="color: ${issue.state === 'open' ? '#2ea44f' : '#d73a49'}">#${issue.number}</span>
        </h3>
        <div class="issue-meta">
          Status: <strong>${issue.state}</strong> | 
          Created: ${new Date(issue.created_at).toLocaleDateString()}
        </div>
        <div>${issue.labels.map(label => `
          <span class="label" style="background-color: #${label.color}">${label.name}</span>
        `).join('')}</div>
        <p>${issue.body?.substring(0, 150) || ''}...</p>
      </div>
    `).join('');
  }

  function filterIssues(filter) {
    document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');
    
    let filtered = allIssues;
    if (filter === 'open') filtered = filtered.filter(i => i.state === 'open');
    if (filter === 'closed') filtered = filtered.filter(i => i.state === 'closed');
    if (filter === 'bug') filtered = filtered.filter(i => i.labels.some(l => l.name === 'bug'));
    if (filter === 'enhancement') filtered = filtered.filter(i => i.labels.some(l => l.name === 'enhancement'));
    
    renderIssues(filtered);
  }

  // Initial load
  fetchIssues();
</script>
