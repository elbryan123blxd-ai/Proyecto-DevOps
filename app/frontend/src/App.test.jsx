import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import App from "../App.jsx";

describe("App", () => {
  it("muestra el titulo de la tienda", () => {
    render(<App />);
    expect(screen.getByText(/CloudOps Store/i)).toBeInTheDocument();
  });
});