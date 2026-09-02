import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("hx", {
    description: "Insert helix context (selection + filename) into message",
    handler: async (_args, ctx) => {
      const contextPath = join(homedir(), ".pi", "helix-context");

      let content: string;
      try {
        content = readFileSync(contextPath, "utf-8");
      } catch (error) {
        if ((error as NodeJS.ErrnoException).code === "ENOENT") {
          ctx.ui.notify("No helix context available (~/.pi/helix-context not found)", "info");
          return;
        }
        ctx.ui.notify(`Error reading helix context: ${(error as Error).message}`, "error");
        return;
      }

      if (!content.trim()) {
        ctx.ui.notify("Helix context is empty", "info");
        return;
      }

      // Format as code block
      const formatted = `\`\`\`\n${content}\n\`\`\``;

      // Insert into message editor
      ctx.ui.setEditorText(formatted);
      ctx.ui.notify("Helix context inserted. Edit and send when ready.", "info");
    },
  });
}
