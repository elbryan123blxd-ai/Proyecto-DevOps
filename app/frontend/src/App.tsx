import { useCallback, useEffect, useState } from "react";
import { createOrder, fetchProducts } from "./api";
import Cart from "./components/Cart";
import Checkout from "./components/Checkout";
import Confirmation from "./components/Confirmation";
import ProductCard from "./components/ProductCard";
import { categories, getMeta } from "./products";
import type { CartItem, Order, OrderCreate, Product } from "./types";

type View = "catalog" | "checkout" | "confirmation";

export default function App() {
  const [products, setProducts] = useState<Product[]>([]);
  const [cart, setCart] = useState<Record<number, CartItem>>({});
  const [view, setView] = useState<View>("catalog");
  const [order, setOrder] = useState<Order | null>(null);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchProducts()
      .then(setProducts)
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  const cartItems = useCallback(() => Object.values(cart), [cart]);

  function addToCart(product: Product) {
    setCart((prev) => {
      const current = prev[product.id];
      return {
        ...prev,
        [product.id]: {
          product,
          quantity: Math.min((current?.quantity ?? 0) + 1, product.stock),
        },
      };
    });
  }

  function increase(productId: number) {
    setCart((prev) => {
      const item = prev[productId];
      if (!item) return prev;
      return {
        ...prev,
        [productId]: {
          ...item,
          quantity: Math.min(item.quantity + 1, item.product.stock),
        },
      };
    });
  }

  function decrease(productId: number) {
    setCart((prev) => {
      const item = prev[productId];
      if (!item) return prev;
      if (item.quantity <= 1) {
        const { [productId]: _removed, ...rest } = prev;
        return rest;
      }
      return { ...prev, [productId]: { ...item, quantity: item.quantity - 1 } };
    });
  }

  function removeItem(productId: number) {
    setCart((prev) => {
      const { [productId]: _removed, ...rest } = prev;
      return rest;
    });
  }

  const total = cartItems().reduce(
    (sum, item) => sum + item.product.price * item.quantity,
    0
  );

  function goCheckout() {
    setError("");
    setView("checkout");
  }

  async function handleCheckout(name: string, email: string) {
    const items = cartItems().map((item) => ({
      product_id: item.product.id,
      quantity: item.quantity,
    }));
    const payload: OrderCreate = {
      customer_name: name,
      customer_email: email,
      items,
    };
    setSubmitting(true);
    setError("");
    try {
      const created = await createOrder(payload);
      setOrder(created);
      setCart({});
      setView("confirmation");
    } catch (e) {
      setError(e instanceof Error ? e.message : "No se pudo crear el pedido");
    } finally {
      setSubmitting(false);
    }
  }

  function backToCatalog() {
    setOrder(null);
    setView("catalog");
  }

  const grouped = categories
    .map((cat) => ({
      category: cat,
      items: products.filter((p) => getMeta(p.name).category === cat),
    }))
    .filter((g) => g.items.length > 0);

  return (
    <div className="app">
      <header className="header">
        <div className="header-left">
          <h1>☁️ cloudops-store <span className="badge-v2">v4</span></h1>
          <span className="tagline">Tu tienda de servicios cloud — canary rollout</span>
        </div>
        <div className="header-pills">
          <span className="pill pill-ok">● Healthy</span>
          <span className="pill pill-region">us-east-1</span>
          <span className="pill pill-count">{products.length} servicios</span>
        </div>
      </header>

      {loading && <p className="empty">Cargando catálogo...</p>}
      {!loading && error && !viewCheckout(view) && <p className="error">{error}</p>}

      {!loading && view === "catalog" && (
        <main className="layout">
          <section className="catalog">
            {grouped.map((g) => (
              <div key={g.category} className="category-group">
                <h2 className="category-title">
                  <span
                    className="category-dot"
                    style={{ background: getMeta(g.items[0].name).color }}
                  />
                  {g.category}
                </h2>
                <div className="grid">
                  {g.items.map((product) => (
                    <ProductCard
                      key={product.id}
                      product={product}
                      quantityInCart={cart[product.id]?.quantity ?? 0}
                      onAdd={addToCart}
                    />
                  ))}
                </div>
              </div>
            ))}
          </section>
          <Cart
            items={cartItems()}
            onIncrease={increase}
            onDecrease={decrease}
            onRemove={removeItem}
            onCheckout={goCheckout}
          />
        </main>
      )}

      {view === "checkout" && (
        <main className="center">
          <Checkout
            total={total}
            onSubmit={handleCheckout}
            onBack={backToCatalog}
            error={error}
            loading={submitting}
          />
        </main>
      )}

      {view === "confirmation" && order && (
        <main className="center">
          <Confirmation order={order} onBack={backToCatalog} />
        </main>
      )}

      <footer className="footer">
        demo DevOps · FastAPI + React + Worker · GitOps con ArgoCD
      </footer>
    </div>
  );
}

function viewCheckout(view: View) {
  return view !== "catalog";
}
