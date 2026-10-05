-- lua/plugins/surround.lua
return {
  "kylechui/nvim-surround",
  -- Используйте стабильную версию для предсказуемости.
  -- Можно заменить на "*" или убрать, чтобы использовать ветку main.
  version = "^4.0.0", 
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      -- Здесь можно переопределить стандартные настройки.
      -- Например, изменить поведение курсора после операции.
      -- move_cursor = false, 
      
      -- Или добавить собственные "окружения".
      -- Подробнее см. `:h nvim-surround.configuration`
    })
  end,
}
