import {fileURLToPath} from 'node:url';
const nextConfig = { outputFileTracingRoot: fileURLToPath(new URL('.', import.meta.url)), experimental: { cpus: 2 } };
export default nextConfig;
