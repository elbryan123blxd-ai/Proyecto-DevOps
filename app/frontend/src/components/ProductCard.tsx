import type { Product } from "../types";
import { getMeta } from "../products";

type Props = {
  product: Product;
  quantityInCart: number;
  onAdd: (product: Product) => void;
};

export default function ProductCard({ product, quantityInCart, onAdd }: Props) {
  const soldOut = product.stock === 0;
  const meta = getMeta(product.name);
  const stockPct = Math.min(100, Math.round((product.stock / 20) * 100));

  return (
    <article className="card">
      <div className="card-icon" style={{ background: `linear-gradient(135deg, ${meta.color}22, ${meta.color}55)` }}>
        <span className="card-emoji">{meta.icon}</span>
      </div>
      <div className="card-category" style={{ color: meta.color }}>{meta.category}</div>
      <h3>{product.name}</h3>
      <p className="desc">{product.description}</p>
      <div className="price-row">
        <span className="price">${Number(product.price).toFixed(2)}</span>
        <span className="price-unit">/mes</span>
      </div>
      <div className="stock-bar-track">
        <div
          className="stock-bar-fill"
          style={{
            width: `${stockPct}%`,
            background: soldOut ? "var(--danger)" : meta.color,
          }}
        />
      </div>
      <div className="meta">
        <span className={soldOut ? "stock sold-out" : "stock"}>
          {soldOut ? "Sin stock" : `${product.stock} en stock`}
        </span>
      </div>
      <button
        className="btn btn-primary"
        onClick={() => onAdd(product)}
        disabled={soldOut || quantityInCart >= product.stock}
      >
        {quantityInCart > 0 ? `En carrito (${quantityInCart})` : "Agregar"}
      </button>
    </article>
  );
}