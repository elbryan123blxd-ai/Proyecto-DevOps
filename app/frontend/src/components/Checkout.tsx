import { FormEvent, useState } from "react";

type Props = {
  total: number;
  onSubmit: (name: string, email: string) => Promise<void>;
  onBack: () => void;
  error: string;
  loading: boolean;
};

export default function Checkout({ total, onSubmit, onBack, error, loading }: Props) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");

  async function handleSubmit(e: FormEvent) {
    e.preventDefault();
    await onSubmit(name, email);
  }

  return (
    <div className="checkout">
      <h2>Checkout</h2>
      <p className="checkout-total">
        Total a pagar: <strong>${total.toFixed(2)}</strong>
      </p>
      <form onSubmit={handleSubmit}>
        <label>
          Nombre
          <input
            required
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="Tu nombre"
          />
        </label>
        <label>
          Email
          <input
            required
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="tu@email.com"
          />
        </label>
        {error && <p className="error">{error}</p>}
        <div className="checkout-actions">
          <button type="button" className="btn btn-ghost" onClick={onBack} disabled={loading}>
            Volver
          </button>
          <button type="submit" className="btn btn-primary" disabled={loading}>
            {loading ? "Procesando..." : "Confirmar pedido"}
          </button>
        </div>
      </form>
    </div>
  );
}