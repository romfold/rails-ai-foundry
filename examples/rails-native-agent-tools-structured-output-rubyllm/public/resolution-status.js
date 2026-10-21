// Refresh only the status frame, at most 120 times per page visit.
let timer;
let count = 0;
function schedule() {
  clearTimeout(timer);
  const frame = document.getElementById('resolution-status');
  if (!frame || frame.querySelector('#state')?.dataset.terminal === 'true' || count >= 120) return;
  timer = setTimeout(() => {
    count += 1;
    if (frame.src) frame.reload();
    else frame.src = frame.dataset.statusUrl;
  }, 3000);
}
document.addEventListener('turbo:load', () => { count = 0; schedule(); });
document.addEventListener('turbo:frame-load', schedule);
document.addEventListener('turbo:before-cache', () => clearTimeout(timer));
