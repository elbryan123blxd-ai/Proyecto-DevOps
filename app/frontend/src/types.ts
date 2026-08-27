export type Product = {
  id: number;
  name: string;
  description: string;
  price: number;
  stock: number;
  created_at: string;
};

export type CartItem = {
  product: Product;
  quantity: number;
};

export type OrderItemIn = {
  product_id: number;
  quantity: number;
};

export type OrderCreate = {
  customer_name: string;
  customer_email: string;
  items: OrderItemIn[];
};

export type OrderItem = {
  product_id: number;
  quantity: number;
  unit_price: number;
};

export type Order = {
  id: number;
  customer_name: string;
  customer_email: string;
  status: string;
  total: number;
  created_at: string;
  items: OrderItem[];
};