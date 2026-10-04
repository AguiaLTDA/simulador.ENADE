import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  experimental: {
    serverActions: {
      // Importação de até 500 questões por planilha (padrão do Next: 1MB).
      bodySizeLimit: "4mb",
    },
  },
};

export default nextConfig;
