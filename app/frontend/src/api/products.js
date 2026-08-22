const BASE = import.meta.env.VITE_API_URL || "/api";

export async function listProducts() {
  const res = await fetch(`${BASE}/products`);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

export async function createProduct(payload) {
  const res = await fetch(`${BASE}/products`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}