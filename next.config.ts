import type {NextConfig} from 'next';
import path from 'node:path';
const config:NextConfig={webpack(config,{webpack}){config.plugins.push(new webpack.NormalModuleReplacementPlugin(/^cloudflare:workers$/,path.resolve(process.cwd(),'lib/netlify-env.ts')));return config;},async headers(){return [{source:'/(.*)',headers:[{key:'X-Content-Type-Options',value:'nosniff'},{key:'Referrer-Policy',value:'no-referrer'},{key:'X-Frame-Options',value:'DENY'}]},{source:'/admin',headers:[{key:'X-Robots-Tag',value:'noindex, nofollow'}]}];}};
export default config;
