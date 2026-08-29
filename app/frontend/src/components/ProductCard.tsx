import type { Product } from "../types";

type Props = {
  product: Product;
  quantityInCart: number;
  onAdd: (product: Product) => void;
};

export default function ProductCard({ product, quantityInCart, onAdd }: Props) {
  const soldOut = product.stock === 0;

  return (
    <article className="card">
      <div className="card-body">
        <h3>{product.name}</h3>
        <p className="desc">{product.description}</p>
        <div className="meta">
          <span className="price">${Number(product.price).toFixed(2)}</span>
          <span className={soldOut ? "stock sold-out" : "stock"}>
            {soldOut ? "Sin stock" : `${product.stock} en stock`}
          </span>
        </div>
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