export function diagnostics(api: any): void {
  const version = Number(api.getVersion());
  if (Number.isFinite(version) && version < 1.5) {
    throw new Error(`Return to Tristram requires D2RMM 1.5 or newer; detected ${version}.`);
  }
  console.log('[Return to Tristram] preflight: D2RMM=' + String(api.getVersion()));
  console.log('[Return to Tristram] reserved: level 139; items dme/rk1/coe/mh1; monster rtt_riftguardian_t1.');
}
