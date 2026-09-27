const chat = document.getElementById('chat');
const feed = document.getElementById('feed');
const input = document.getElementById('message-input');
const suggestions = document.getElementById('suggestions');
const modeLabel = document.getElementById('mode-label');
let modes = {};
let commands = {};
let maxHistory = 120;
let isOpen = false;

const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'sk-streetchat';
const nui = (name, data = {}) => fetch(`https://${resource}/${name}`, { method:'POST', headers:{'Content-Type':'application/json; charset=UTF-8'}, body:JSON.stringify(data) });

function escapeHtml(value) { const node = document.createElement('span'); node.textContent = value; return node.innerHTML; }
function selectedMode(value) {
  const found = value.match(/^\/(\S+)/);
  return found && commands[found[1]] ? found[1] : 'localChat';
}
function renderMode(value) {
  const mode = selectedMode(value);
  const item = mode === 'localChat' ? modes.localChat : commands[mode];
  const label = item?.label || 'LOCAL';
  const suffix = mode === 'localChat' ? 'CHAT' : 'CHANNEL';
  modeLabel.innerHTML = `${escapeHtml(label)} <em>${suffix}</em>`;
  const token = value.match(/^\/(\w*)$/)?.[1]?.toLowerCase();
  if (token === undefined) { suggestions.classList.remove('active'); return; }
  const matches = Object.entries(commands).filter(([key]) => key.startsWith(token));
  suggestions.innerHTML = matches.map(([key, item]) => `<button class="suggestion" data-command="${key}"><b>/${key}</b> ${escapeHtml(item.description)}</button>`).join('');
  suggestions.classList.toggle('active', matches.length > 0);
}
function addMessage(message) {
  const mode = modes[message.mode] || commands[message.mode] || modes.localChat || { label:'LOCAL', color:'#f5d336' };
  const row = document.createElement('article');
  row.className = 'message'; row.style.setProperty('--tag', mode.color);
  row.innerHTML = `<span class="tag">${escapeHtml(mode.label)}</span><span class="text"><b class="author">${escapeHtml(message.author || 'UNKNOWN')}</b> ${escapeHtml(message.text || '')}</span><time class="time">${escapeHtml(message.time || '')}</time>`;
  feed.appendChild(row);
  while (feed.children.length > maxHistory) feed.firstElementChild.remove();
  feed.scrollTop = feed.scrollHeight;
}
function open(prefill = '') { isOpen = true; chat.classList.remove('closed'); input.value = prefill; renderMode(prefill); requestAnimationFrame(() => { input.focus(); input.setSelectionRange(input.value.length, input.value.length); }); }
function close() { isOpen = false; chat.classList.add('closed'); input.value = ''; suggestions.classList.remove('active'); }

window.addEventListener('message', (event) => {
  const data = event.data || {};
  if (data.action === 'configure') { modes = data.modes || {}; commands = data.commands || {}; maxHistory = data.maxHistory || maxHistory; }
  if (data.action === 'open') open(data.prefill || '');
  if (data.action === 'close') close();
  if (data.action === 'message') addMessage(data);
});
input.addEventListener('input', () => renderMode(input.value));
input.addEventListener('keydown', (event) => {
  if (event.key === 'Escape') { event.preventDefault(); nui('close'); return; }
  if (event.key !== 'Enter') return;
  event.preventDefault();
  let value = input.value.trim(); if (!value) return nui('close');
  let command = selectedMode(value);
  if (command !== 'localChat') value = value.replace(/^\/\S+\s*/, '');
  if (value) nui('send', { command, text:value }); else nui('close');
});
suggestions.addEventListener('click', (event) => { const button = event.target.closest('[data-command]'); if (!button) return; input.value = `/${button.dataset.command} `; input.focus(); renderMode(input.value); });
close();
