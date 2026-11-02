declare namespace Cloudflare {
  interface Env {
    BELEG_GATEWAY_KEY?: string;
    BELEG_TEST_API_URL?: string;
    DB?: D1Database;
    BUCKET?: R2Bucket;
    BELEG_GATEWAY_KEY?: string;
    AZURE_SPEECH_KEY?: string;
    AZURE_SPEECH_REGION?: string;
  }
}
