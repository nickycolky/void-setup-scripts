function fastfetch-setup
    echo "📂 Creating fastfetch config directory..."
    mkdir -p ~/.config/fastfetch/

    echo "📝 Writing config.jsonc..."
    printf '%s\n' '{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

 "logo":
    {
    "color": {"2": "white"},
    "padding": {"top": 2, "left": 3},
    },

  "display": {
    "color": "94",
    "separator": "    "
  },
  "modules": [
    "break",
    {

      "type": "custom",
      "format": "                                                                                                "
    },
  {

      "type": "custom",
      "format": "                                                                                                "
    },
    {

      "type": "custom",
      "format": "                                                                                                "
    },
   {
      "type": "title",
      "key": "  ",
      "format": "{6} @void"
    },
    {

      "type": "custom",
      "format": " ────────────────────────────────"
    },
    {
      "type": "os",
      "key": "  ",
      "format": "{3}"
    },
    {
      "type": "kernel",
      "key": "  "
    },
    {
      "type": "packages",
      "key": " 󰏗 "
    },
    {
      "type": "disk",
      "key": "  ",
      "format": "{1} / {2} ({3})"
    },
    {
      "type": "memory",
      "key": " 󰟖 ",
      "format": "{1} / {2} ({3})"
    },
    {
      "type": "swap",
      "key": " 󰿡 ",
      "format": "{1} / {2} ({3})"
    },
    {
      "type": "bootmgr",
      "key": " 󱗈 ",
      "format": "{1}"
    },
    {
      "type": "initsystem",
      "key": " 󰑮 ",
      "format": "{1}"
    },
    {
      "type": "de",
      "key": "  ",
    },
    {
      "type": "shell",
      "key": "  "
    },
    {
      "type": "battery",
      "key": " 󱊥 ",
      "format": "{12} hours {13} minutes ({4}) - {5}"
    },
    {
      "type": "custom",
      "format": " ────────────────────────────────"
    }
  ]
}' | tee ~/.config/fastfetch/config.jsonc > /dev/null

    echo "✅ fastfetch configuration done!"
end
