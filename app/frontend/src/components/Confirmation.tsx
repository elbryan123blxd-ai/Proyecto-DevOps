import type { Order } from "../types";

type Props = {
  order: Order;
  onBack: () => void;
};

export default function Confirmation({ order, onBack }: Props) {
  return (
    <div className="confirmation">
      <h2>Pedido confirmado 🎉</h2>
      <p>
        Gracias {order.customer_name}, tu pedido <strong>#{order.id}</strong> está en
        estado <strong className="badge">{order.status}</strong> y se está procesando.
      </p>
      <ul className="confirm-items">
        {order.items.map((item) => (
          <li key={item.product_id}>
            Producto {item.product_id} x{item.quantity} — $
            {(item.unit_price * item.quantity).toFixed(2)}
          </li>
        ))}
      </ul>
      <p className="confirm-total">Total: <strong>${Number(order.total).toFixed(2)}</strong></p>
      <button className="btn btn-primary" onClick={onBack}>
        Volver al catálogo
      </button>
    </div>
  );
}