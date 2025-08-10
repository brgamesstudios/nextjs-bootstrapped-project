const appEl = document.getElementById('app');
const itemsEl = document.getElementById('items');
const shopLabelEl = document.getElementById('shopLabel');
const closeBtn = document.getElementById('close');
const searchInput = document.getElementById('search');
const searchBtn = document.getElementById('searchBtn');

let currentShop = null;
let currentQuery = '';

function setVisible(visible) {
  appEl.classList.toggle('hidden', !visible);
}

function normalize(text) {
  return String(text || '').toLowerCase();
}

function filteredItems() {
  const all = currentShop?.items || [];
  if (!currentQuery) return all;
  const q = normalize(currentQuery);
  return all.filter(it => normalize(it.label).includes(q) || normalize(it.name).includes(q));
}

function render(shop) {
  currentShop = shop || currentShop;
  shopLabelEl.textContent = currentShop?.label || 'Shop';
  const currency = currentShop?.currency || '$';
  itemsEl.innerHTML = '';
  filteredItems().forEach(item => {
    const card = document.createElement('div');
    card.className = 'card';

    const info = document.createElement('div');
    info.className = 'info';

    const label = document.createElement('div');
    label.className = 'label';
    label.textContent = item.label;

    const price = document.createElement('div');
    price.className = 'price';
    price.textContent = `${currency}${item.price}`;

    info.appendChild(label);
    info.appendChild(price);

    const qtyWrap = document.createElement('div');
    qtyWrap.className = 'qty';

    const qtyInput = document.createElement('input');
    qtyInput.type = 'number';
    qtyInput.min = '1';
    qtyInput.step = '1';
    qtyInput.value = '1';

    const buyBtn = document.createElement('button');
    buyBtn.className = 'buy';
    buyBtn.textContent = 'Buy';

    buyBtn.addEventListener('click', () => {
      fetch(`https://${GetParentResourceName()}/buyItem`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ name: item.name, quantity: Number(qtyInput.value) || 1 })
      });
    });

    qtyWrap.appendChild(qtyInput);
    qtyWrap.appendChild(buyBtn);

    card.appendChild(info);
    card.appendChild(qtyWrap);

    itemsEl.appendChild(card);
  });
}

window.addEventListener('DOMContentLoaded', () => {
  setVisible(false);
});

window.addEventListener('message', (event) => {
  const { action, shop } = event.data || {};
  if (action === 'open') {
    console.log('[market_ui] open payload', shop);
    setVisible(true);
    render(shop);
  } else if (action === 'update') {
    render(shop);
  } else if (action === 'close') {
    setVisible(false);
  }
});

closeBtn.addEventListener('click', () => {
  fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
});

window.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    fetch(`https://${GetParentResourceName()}/close`, { method: 'POST' });
  }
});

searchInput?.addEventListener('input', (e) => {
  currentQuery = e.target.value || '';
  render();
});

searchBtn?.addEventListener('click', () => {
  if (!searchInput) return;
  if (currentQuery) {
    currentQuery = '';
    searchInput.value = '';
    render();
  }
  searchInput.focus();
});