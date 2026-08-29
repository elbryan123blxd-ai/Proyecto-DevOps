import type { CartItem } from "../types";

type Props = {
  items: CartItem[];
  onIncrease: (productId: number) => void;
  onDecrease: (productId: number) => void;
  onRemove: (productId: number) => void;
  onCheckout: () => void;
};

export default function Cart({ items, onIncrease, onDecrease, onRemove, onCheckout }: Props) {
  if (items.length === 0) {
    return <p className="empty">Tu carrito está vacío. Agregá productos del catálogo.</p>;
  }

  const total = items.reduce(
    (sum, item) => sum + Number(item.product.price) * item.quantity,
    0
  );

  return (
    <aside className="cart">
      <h2>Carrito</h2>
      <ul>
        {items.map((item) => (
          <li key={item.product.id} className="cart-row">
            <div className="cart-info">
              <span className="cart-name">{item.product.name}</span>
              <span className="cart-price">
                ${(Number(item.product.price) * item.quantity).toFixed(2)}
              </span>
            </div>
            <div className="cart-actions">
              <button className="btn btn-mini" onClick={() => onDecrease(item.product.id)}>
                -
              </button>
              <span className="cart-qty">{item.quantity}</span>
              <button className="btn btn-mini" onClick={() => onIncrease(item.product.id)}>
                +
              </button>
              <button className="btn btn-mini btn-ghost" onClick={() => onRemove(item.product.id)}>
                x
              </button>
            </div>
          </li>
        ))}
      </ul>
      <div className="cart-total">
        <span>Total</span>
        <strong>${total.toFixed(2)}</strong>
      </div>
      <button className="btn btn-primary btn-block" onClick={onCheckout}>
        Finalizar compra
      </button>
    </aside>
  );
}