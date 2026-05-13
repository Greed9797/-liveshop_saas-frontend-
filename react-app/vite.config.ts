import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'
import { defineConfig, loadEnv } from 'vite'

function normalizeProxyTarget(raw?: string): string | undefined {
  if (!raw?.trim()) return undefined
  return raw.trim().replace(/\/v1\/?$/, '').replace(/\/+$/, '')
}

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const proxyTarget = normalizeProxyTarget(env.VITE_DEV_API_PROXY_TARGET)
  const proxyOrigin = env.VITE_DEV_API_PROXY_ORIGIN?.trim() || 'https://livelab-3601f.web.app'

  return {
    plugins: [react(), tailwindcss()],
    build: {
      rollupOptions: {
        output: {
          manualChunks: {
            react: ['react', 'react-dom', 'react-router-dom'],
            query: ['@tanstack/react-query', 'zustand', 'axios'],
            charts: ['recharts'],
            icons: ['lucide-react'],
          },
        },
      },
    },
    server: {
      host: '0.0.0.0',
      port: 5173,
      proxy: proxyTarget
        ? {
            '/v1': {
              target: proxyTarget,
              changeOrigin: true,
              secure: true,
              headers: {
                Origin: proxyOrigin,
              },
            },
          }
        : undefined,
    },
  }
})
