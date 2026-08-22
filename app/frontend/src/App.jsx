import { useEffect, useState } from "react";
import { listProducts, createProduct } from "./api/products.js";

const API_URL = import.meta.env.VITE_API_URL || "/api";

export default function App() {
  const [products, setProducts] = useState([]);
  const [name, setName] = useState("");
  const [price, setPrice] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const load = async () => {
    try {
      setLoading(true);
      setProducts(await listProducts());
      setError(null);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const onSubmit = async (e) => {
    e.preventDefault();
    if (!name) return;
    await createProduct({ name, price: Number(price), stock: 0 });
    setName("");
    setPrice(0);
    load();
  };

  return (
    <main style={{ fontFamily: "sans-serif", padding: "1rem", maxWidth: 640, margin: "0 auto" }}>
      <h1>🛒 CloudOps Store</h1>
      <p>App de 3 capas desplegada con GitOps en EKS.</p>
      <p>
        API: <code>{API_URL}</code>
      </p>

      {error && <p style={{ color: "red" }}>Error: {error}</p>}

      <form onSubmit={onSubmit} style={{ display: "flex", gap: "0.5rem", marginBottom: "1rem" }}>
        <input
          placeholder="Nombre del producto"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
        <input
          type="number"
          placeholder="Precio"
          value={price}
          onChange={(e) => setPrice(e.target.value)}
        />
        <button type="submit">Agregar</button>
      </form>

      {loading ? (
        <p>Cargando...</p>
      ) : (
        <ul>
          {products.map((p) => (
            <li key={p.id}>
              {p.name} — ${p.price.toFixed(2)} (stock {p.stock})
            </li>
          ))}
        </ul>
      )}
    </main>
  );
}