/**
 * notify plugin - plays sound when a session becomes idle
 *
 * uses macos afplay to play a system sound when a response completes
 */

import type { Plugin } from "@opencode-ai/plugin";

const SOUNDS = {
  success: "/System/Library/Sounds/Glass.aiff",
  error: "/System/Library/Sounds/Basso.aiff",
  complete: "/System/Library/Sounds/Ping.aiff",
};

async function playSound(sound: keyof typeof SOUNDS): Promise<void> {
  try {
    Bun.spawn(["afplay", SOUNDS[sound]], {
      stdout: "ignore",
      stderr: "ignore",
    });
  } catch {}
}

export const NotifyPlugin: Plugin = async () => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await playSound("complete");
      }
    },
  };
};

export default NotifyPlugin;
