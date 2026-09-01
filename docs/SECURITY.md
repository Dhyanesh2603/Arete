# Arete OS — Security, Privacy, and Cryptography Architecture

---

## 1. Security Philosophy and Threat Model

Arete operates as a sovereign personal operating system. Users store their most critical life ambitions, proprietary project architectures, and deeply personal cognitive reflections within the platform. The security model guarantees:
1. **Zero-Knowledge Privacy for Sensitive Notes**: Personal reflections and proprietary notes can be end-to-end encrypted before leaving the client device.
2. **Strict Multi-Tenant Isolation**: Enforced at the database engine level via PostgreSQL Row Level Security (RLS).
3. **Zero Third-Party Tracking**: No external behavioral ad trackers, pixel trackers, or data broker integrations.

---

## 2. End-to-End Encryption (E2EE) Architecture

```
[ User Input Note / Reflection ]
               |
               v
[ Client-Side AES-256-GCM Encryption ] <--- [ Encryption Key derived via PBKDF2/Argon2 from User Master Key ]
               |
               v
[ Encrypted Ciphertext + IV Payload ]
               |
               v
[ Supabase PostgreSQL Storage ] (Server possesses zero ability to decrypt note content)
```

### Key Derivation and Storage
- **Algorithm**: PBKDF2 with SHA-256 (100,000 iterations) or Argon2id.
- **Web Storage**: Master key material is stored in memory during active session; persistent local caches use the Web Crypto API.
- **Android Storage**: Keys are secured using the **Android KeyStore** hardware security module (HSM).

---

## 3. Row Level Security (RLS) Enforcement

Every table in PostgreSQL is protected by strict RLS policies bound directly to the authenticated JWT subject (`auth.uid()`):
- Users can never query, insert, update, or delete records belonging to another `user_id`.
- Edge Functions execute with limited service roles and validate user claims on every invocation.

---

## 4. Web Application Security Standards

### Content Security Policy (CSP) for Flutter Web
```http
Content-Security-Policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline'; font-src 'self' data:; connect-src 'self' https://*.supabase.co wss://*.supabase.co; img-src 'self' data: https:; media-src 'self' blob:;
```

### Additional Web Defenses
- **Cross-Site Scripting (XSS)**: All markdown rendering uses strict sanitization engines blocking script injections, raw iframe embeds, and malicious URL schemas.
- **Cross-Origin Resource Sharing (CORS)**: Strict origin whitelisting allowing only the verified Arete web domains.
- **JWT Rotation**: Supabase GoTrue auto-rotates access tokens every 60 minutes with secure HTTP-only refresh tokens.
