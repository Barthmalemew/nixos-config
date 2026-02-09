{ pkgs, ... }:

{
  # Use xdg.configFile for cleaner paths (automatically maps to ~/.config/...)
  # Use builtins.toJSON to ensure valid JSON generation from Nix data structures.
  xdg.configFile."opencode/config.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/config.json";
    plugin = [ "opencode-gemini-auth@latest" "./plugins/mandrid-pack.js" ];
    
    permission = {
      read = "allow";
      list = "allow";
      glob = "allow";
      grep = "allow";

      edit = "ask";
      bash = "ask";
      task = "ask";
      webfetch = "ask";
      external_directory = "ask";
    };
  };

  # Auto-inject a tiny Mandrid pack into every user message.
  # This mimics ByteRover's hook connector behavior without wrappers.
  xdg.configFile."opencode/plugins/mandrid-pack.js".text = ''
    export const MandridPackPlugin = async ({ $, worktree }) => {
      const shell = $.cwd(worktree).nothrow();

      const env = (key, fallback) => {
        const v = (globalThis.process && process.env && process.env[key]) || "";
        return v && v.length > 0 ? v : fallback;
      };

      const toInt = (v, fallback) => {
        const n = parseInt(v, 10);
        return Number.isFinite(n) ? n : fallback;
      };

      const budget = toInt(env("MANDRID_PACK_BUDGET", "700"), 700);
      const kEpisodic = toInt(env("MANDRID_PACK_EPISODIC", "2"), 2);
      const kCode = toInt(env("MANDRID_PACK_CODE", "2"), 2);
      const includeCode = env("MANDRID_PACK_INCLUDE_CODE", "0") === "1";
      const trimHistory = env("MANDRID_PACK_TRIM_HISTORY", "0") === "1";
      const disable = env("MANDRID_PACK_DISABLE", "0") === "1";
      const capsRaw = env("MANDRID_PACK_TYPE_CAPS", "trace=2,thought=1,task=2,auto=2,interaction=1");
      const capsNormalized = capsRaw.trim().replace(/\s+/g, "");
      const capsLower = capsNormalized.toLowerCase();
      const useCaps = !!capsNormalized && capsLower !== "0" && capsLower !== "off" && capsLower !== "false";

      const isTrivial = (text) => {
        const t = text.trim().toLowerCase();
        if (t.length < 8) return true;
        return ["ok", "okay", "thanks", "thx", "yep", "no", "yes", "sure", "cool", "k", "👍", "👌"].includes(t);
      };

      async function runPack(text) {
        if (!text || !text.trim()) return "";
        if (isTrivial(text)) return "";
        if (disable) return "";
        try {
          let cmd;
          if (includeCode) {
            if (useCaps) {
              cmd = shell`mem pack --scope session --token-budget ''${budget} --k-episodic ''${kEpisodic} --type-caps ''${capsNormalized} --include-code --k-code ''${kCode} -- ''${text}`;
            } else {
              cmd = shell`mem pack --scope session --token-budget ''${budget} --k-episodic ''${kEpisodic} --include-code --k-code ''${kCode} -- ''${text}`;
            }
          } else if (useCaps) {
            cmd = shell`mem pack --scope session --token-budget ''${budget} --k-episodic ''${kEpisodic} --type-caps ''${capsNormalized} -- ''${text}`;
          } else {
            cmd = shell`mem pack --scope session --token-budget ''${budget} --k-episodic ''${kEpisodic} -- ''${text}`;
          }
          const out = await cmd.quiet().text();
          return (out || "").trim();
        } catch {
          return "";
        }
      }

      return {
        "experimental.chat.messages.transform": async (_input, output) => {
          if (!trimHistory || !output?.messages?.length) return;
          const msgs = output.messages;
          const lastUserIndex = [...msgs].map((m, i) => ({ m, i })).reverse().find((x) => x.m.info?.role === "user");
          if (lastUserIndex && typeof lastUserIndex.i === "number") {
            output.messages = [msgs[lastUserIndex.i]];
          }
        },
        "chat.message": async (_input, output) => {
          if (!output?.message || output.message.role !== "user") return;
          const parts = output.parts || [];
          const textPart = parts.find((p) => p && p.type === "text" && typeof p.text === "string");
          if (!textPart) return;
          if (textPart.text.startsWith("<mem_pack>")) return;

          const pack = await runPack(textPart.text);
          if (!pack) return;

          textPart.text = pack + "\n\n" + textPart.text;
        },
      };
    };
  '';
}
