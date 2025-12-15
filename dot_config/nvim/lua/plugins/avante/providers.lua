return {
  sonnet_4_5 = {
    __inherited_from = "claude",
    endpoint = "https://api.anthropic.com",
    model = "claude-sonnet-4-5-20250929",
    api_key_name = "cmd:cat ~/.secrets/avante/anthropic_key",
    timeout = 30000,
    extra_request_body = {
      max_tokens = 20480,
    },
  },
  glm_4_6 = {
    __inherited_from = "openai",
    endpoint = "https://openrouter.ai/api/v1",
    model = "z-ai/glm-4.6",
    api_key_name = "cmd:cat ~/.secrets/avante/openrouter_key",
    timeout = 30000,
    extra_request_body = {
      max_tokens = 32768,
    },
  },
  moonshot_thinking = {
    __inherited_from = "openai",
    endpoint = "https://openrouter.ai/api/v1",
    model = "moonshotai/kimi-k2-thinking",
    api_key_name = "cmd:cat ~/.secrets/avante/openrouter_key",
    timeout = 30000,
    extra_request_body = {
      max_tokens = 32768,
    },
  },
  gemini_3 = {
    __inherited_from = "gemini",
    endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
    model = "gemini-3",
    api_key_name = "cmd:cat ~/.secrets/avante/google_key",
    timeout = 30000,
    max_tokens = 32768,
  },
  gpt_5_2 = {
    __inherited_from = "openai",
    endpoint = "https://api.openai.com/v1/responses",
    model = "gpt-5.2",
    api_key_name = "cmd:cat ~/.secrets/avante/openai_key",
    timeout = 30000,
    max_tokens = 32768,
  },
  gpt_5 = {
    __inherited_from = "openai",
    endpoint = "https://api.openai.com/v1/responses",
    model = "gpt-5",
    api_key_name = "cmd:cat ~/.secrets/avante/openai_key",
    timeout = 30000,
    max_tokens = 32768,
  },
  gpt_5_mini = {
    __inherited_from = "openai",
    endpoint = "https://api.openai.com/v1/responses",
    model = "gpt-5-mini",
    api_key_name = "cmd:cat ~/.secrets/avante/openai_key",
    timeout = 30000,
    max_tokens = 32768,
  },
}

