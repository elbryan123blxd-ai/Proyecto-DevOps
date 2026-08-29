export type ProductMeta = {
  icon: string;
  category: string;
  color: string;
};

const meta: Record<string, ProductMeta> = {
  "EC2 Micro (1 mes)": {
    icon: "\u{1F5A5}",
    category: "C\u00f3mputo",
    color: "#3b82f6",
  },
  "S3 Bucket (1 GB)": {
    icon: "\u{1F5C4}",
    category: "Storage",
    color: "#10b981",
  },
  "RDS Postgres (1 mes)": {
    icon: "\u{1F5C3}",
    category: "Bases de datos",
    color: "#8b5cf6",
  },
  "Lambda Fan-out": {
    icon: "\u26A1",
    category: "Serverless",
    color: "#f59e0b",
  },
  "CloudFront CDN": {
    icon: "\u{1F310}",
    category: "Edge",
    color: "#06b6d4",
  },
  "EKS Node Group": {
    icon: "\u2638",
    category: "Orquestaci\u00f3n",
    color: "#6366f1",
  },
  "Grafana Dashboard": {
    icon: "\u{1F4C8}",
    category: "Observabilidad",
    color: "#ec4899",
  },
  "ArgoCD Rollout": {
    icon: "\u{1F6A2}",
    category: "GitOps",
    color: "#14b8a6",
  },
};

const fallback: ProductMeta = {
  icon: "\u2699",
  category: "Otros",
  color: "#64748b",
};

export function getMeta(name: string): ProductMeta {
  if (meta[name]) return meta[name];
  const key = Object.keys(meta).find((k) => name.startsWith(k.split(" ")[0]));
  return key ? meta[key] : fallback;
}

export const categories = [
  "C\u00f3mputo",
  "Storage",
  "Bases de datos",
  "Serverless",
  "Edge",
  "Orquestaci\u00f3n",
  "Observabilidad",
  "GitOps",
  "Otros",
];
