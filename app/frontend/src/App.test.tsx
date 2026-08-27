import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import App from "./App";

const mockProducts = [
  {
    id: 1,
    name: "EC2 Micro",
    description: "Cómputo ligero",
    price: 12.5,
    stock: 10,
    created_at: "2026-01-01T00:00:00Z",
  },
  {
    id: 2,
    name: "S3 Bucket",
    description: "Almacenamiento",
    price: 0.23,
    stock: 0,
    created_at: "2026-01-01T00:00:00Z",
  },
];

const mockOrder = {
  id: 7,
  customer_name: "Bryan",
  customer_email: "bryan@example.com",
  status: "pending",
  total: 12.5,
  created_at: "2026-01-01T00:00:00Z",
  items: [{ product_id: 1, quantity: 1, unit_price: 12.5 }],
};

function mockFetch() {
  return vi.fn((url: RequestInfo | URL) => {
    const path = String(url);
    if (path.startsWith("/api/orders")) {
      return Promise.resolve({
        ok: true,
        status: 201,
        json: () => Promise.resolve(mockOrder),
      });
    }
    return Promise.resolve({
      ok: true,
      status: 200,
      json: () => Promise.resolve(mockProducts),
    });
  }) as unknown as typeof fetch;
}

beforeEach(() => {
  globalThis.fetch = mockFetch();
});

afterEach(() => {
  vi.restoreAllMocks();
});

it("muestra el catálogo con precios y stock", async () => {
  render(<App />);
  expect(await screen.findByText("EC2 Micro")).toBeInTheDocument();
  expect(screen.getByText("S3 Bucket")).toBeInTheDocument();
  expect(screen.getByText("Sin stock")).toBeInTheDocument();
  expect(screen.getByText("10 en stock")).toBeInTheDocument();
});

it("agrega al carrito y permite finalizar la compra", async () => {
  const user = userEvent.setup();
  render(<App />);

  const addButtons = await screen.findAllByText("Agregar");
  const addButton = addButtons.find(
    (b) => !(b as HTMLButtonElement).disabled
  ) as HTMLButtonElement;
  expect(addButton).not.toBeDisabled();
  await user.click(addButton);
  expect(screen.getByText("En carrito (1)")).toBeInTheDocument();

  await user.click(screen.getByRole("button", { name: "Finalizar compra" }));
  await user.type(screen.getByPlaceholderText("Tu nombre"), "Bryan");
  await user.type(screen.getByPlaceholderText("tu@email.com"), "bryan@example.com");
  await user.click(screen.getByRole("button", { name: "Confirmar pedido" }));

  expect(await screen.findByText("Pedido confirmado 🎉")).toBeInTheDocument();
  expect(screen.getByText("#7")).toBeInTheDocument();
});