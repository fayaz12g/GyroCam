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
    cursor: pointer;
    transition: all 0.2s;
  }
  .issue-card:hover {
    box-shadow: 0 2px 5px rgba(0,0,0,0.1);
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
    color: white !important;
  }
  .status-open { color: #2ea44f; }
  .status-closed { color: #d73a49; }
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
  .comments-container {
    margin-top: 15px;
    border-top: 1px solid #e1e4e8;
    padding-top: 10px;
  }
  .comment {
    margin: 10px 0;
    padding: 10px;
    background-color: white;
    border-radius: 5px;
  }
  .loading-comments {
    color: #586069;
    font-style: italic;
    padding: 10px;
  }
</style>

<script>
  let allIssues = [];
  
  async function fetchIssues() {
    try {
      const response = await fetch('https://api.github.com/repos/fayaz12g/GyroCam/issues?state=all');
      let issues = await response.json();
      issues = issues.filter(issue => !('pull_request' in issue));
      allIssues = issues;
      renderIssues(issues);
    } catch (error) {
      console.error('Error fetching issues:', error);
      document.getElementById('issues-container').innerHTML = 
        '<p>Error loading issues. Please <a href="https://github.com/fayaz12g/GyroCam/issues" target="_blank">view on GitHub</a>.</p>';
    }
  }

  async function fetchComments(issueNumber) {
    try {
      const response = await fetch(`https://api.github.com/repos/fayaz12g/GyroCam/issues/${issueNumber}/comments`);
      return await response.json();
    } catch (error) {
      console.error('Error fetching comments:', error);
      return [];
    }
  }

  function renderIssues(issues) {
    const container = document.getElementById('issues-container');
    container.innerHTML = issues.map(issue => `
      <div class="issue-card" onclick="toggleComments(${issue.number})">
        <h3 class="issue-title">
          <a href="${issue.html_url}" target="_blank">${issue.title}</a>
          <span class="status-${issue.state}">#${issue.number}</span>
        </h3>
        <div class="issue-meta">
          Status: <strong class="status-${issue.state}">${issue.state}</strong> | 
          Created: ${new Date(issue.created_at).toLocaleDateString()} |
          Comments: ${issue.comments}
        </div>
        <div>${issue.labels.map(label => `
          <span class="label" style="background-color: #${label.color}${label.name === 'bug' ? '; padding: 2px 8px' : ''}">
            ${label.name}
          </span>
        `).join('')}</div>
        <p>${issue.body?.substring(0, 150) || ''}...</p>
        <div id="comments-${issue.number}" class="comments-container" style="display: none;"></div>
      </div>
    `).join('');
  }

  async function toggleComments(issueNumber) {
    const container = document.getElementById(`comments-${issueNumber}`);
    if (container.style.display === 'none') {
      container.innerHTML = '<div class="loading-comments">Loading comments...</div>';
      container.style.display = 'block';
      const comments = await fetchComments(issueNumber);
      container.innerHTML = comments.map(comment => `
        <div class="comment">
          <strong>${comment.user.login}</strong> 
          <span style="color: #586069; font-size: 0.9em;">
            ${new Date(comment.created_at).toLocaleDateString()}
          </span>
          <p>${comment.body}</p>
        </div>
      `).join('') || '<div class="comment">No comments yet</div>';
    } else {
      container.style.display = 'none';
    }
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

  fetchIssues();
</script>
