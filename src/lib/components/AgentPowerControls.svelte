<script lang="ts">
  import type { SessionPreferences } from "$lib/types";
  let { preferences, disabled = false, compact = false, onChange }: {
    preferences: SessionPreferences | null | undefined;
    disabled?: boolean;
    compact?: boolean;
    onChange: (patch: Partial<SessionPreferences>) => void | Promise<void>;
  } = $props();

  function apply(patch: Partial<SessionPreferences>) {
    if (!disabled) void onChange(patch);
  }

  function setMaximum() {
    apply({
      sandboxMode: "danger-full-access",
      approvalPolicy: "never",
      autoApproveMode: "session",
      networkAccess: true
    });
  }

  function setSafe() {
    apply({
      sandboxMode: "workspace-write",
      approvalPolicy: "on-request",
      autoApproveMode: "manual",
      networkAccess: false
    });
  }
</script>

<div class="grid gap-3">
  <div class="flex items-center justify-between gap-3 px-1">
    <div>
      <p class="text-xs font-bold text-gray-900">Potencia del agente</p>
      <p class="text-[10px] text-gray-500">La protección externa de la app permanece activa.</p>
    </div>
  </div>
  <label class="flex items-center justify-between gap-3 rounded-xl border border-gray-200 bg-gray-50/80 px-3 py-2.5">
    <span><strong class="block text-xs">Full Access</strong><small class="text-gray-500">Acceso completo del agente.</small></span>
    <input type="checkbox" checked={preferences?.sandboxMode === "danger-full-access"} disabled={disabled}
      onchange={(event) => apply({ sandboxMode: (event.currentTarget as HTMLInputElement).checked ? "danger-full-access" : "workspace-write" })} />
  </label>

  <label class="flex items-center justify-between gap-3 rounded-xl border border-gray-200 bg-gray-50 px-3 py-2.5">
    <span><strong class="block text-xs">Sin confirmaciones</strong><small class="text-gray-500">No pedir aprobación intermedia.</small></span>
    <input type="checkbox" checked={preferences?.approvalPolicy === "never"} disabled={disabled}
      onchange={(event) => apply({ approvalPolicy: (event.currentTarget as HTMLInputElement).checked ? "never" : "on-request" })} />
  </label>

  <label class="flex items-center justify-between gap-3 rounded-xl border border-gray-200 bg-gray-50 px-3 py-2.5">
    <span><strong class="block text-xs">Auto-aprobar sesión</strong><small class="text-gray-500">Mantener aprobación automática.</small></span>
    <input type="checkbox" checked={preferences?.autoApproveMode === "session"} disabled={disabled}
      onchange={(event) => apply({ autoApproveMode: (event.currentTarget as HTMLInputElement).checked ? "session" : "manual" })} />
  </label>

  <label class="flex items-center justify-between gap-3 rounded-xl border border-gray-200 bg-gray-50 px-3 py-2.5">
    <span><strong class="block text-xs">Internet</strong><small class="text-gray-500">Permitir acceso de red.</small></span>
    <input type="checkbox" checked={preferences?.networkAccess ?? false} disabled={disabled}
      onchange={(event) => apply({ networkAccess: (event.currentTarget as HTMLInputElement).checked })} />
  </label>

  <div class="grid grid-cols-2 gap-2">
    <button type="button" class="rounded-xl border border-gray-200 bg-white px-3 py-2 text-xs font-bold" disabled={disabled} onclick={setSafe}>Modo seguro</button>
    <button type="button" class="rounded-xl bg-gray-950 px-3 py-2 text-xs font-bold text-white" disabled={disabled} onclick={setMaximum}>TODO AL PALO</button>
  </div>
</div>
