/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone',
  // Disable telemetry during build
  typescript: {
    ignoreBuildErrors: true,
  },
  eslint: {
    ignoreDuringBuilds: true,
  },
};

export default nextConfig;
