local M = {}

-- Define default configuration with correct structure
local default_config = {
	default_char = ";", -- fallback char
	ft_map = {
		c = ";",
		cpp = ";",
		rust = ";",
		java = ";",
		python = "",
		lua = "",
	}
}

-- Initialize config
M.config = vim.deepcopy(default_config)

M.setup = function(opts)
	-- Merge user options with default config
	M.config = vim.tbl_deep_extend("force", default_config, opts or {})
end

M.append = function()
	local ft = vim.bo.filetype
	-- Get char from map or use default
	local char = M.config.ft_map[ft]
	if char == nil then char = M.config.default_char end

	-- If char is empty, do nothing
	if char == "" then return end

	local line = vim.api.nvim_get_current_line()
	local cursor = vim.api.nvim_win_get_cursor(0) -- returns {row, col}

	-- Get comment string for current filetype (e.g., "// %s" or "-- %s")
	local comment_str = vim.bo.commentstring
	if not comment_str or comment_str == "" then comment_str = "# %s" end
	
	-- Extract comment leader (e.g., "//")
	local leader = comment_str:match("^(.*)%%s") or comment_str
	leader = vim.trim(leader)

	-- Find comment position
	local c_start = line:find(leader, 1, true)

	local code_part = line
	local comment_part = ""

	-- Split line into code and comment
	if c_start then
		code_part = line:sub(1, c_start - 1)
		comment_part = line:sub(c_start)
	end

	-- Remove trailing spaces from code part
	local clean_code = code_part:gsub("%s+$", "")

	-- Check if the char already exists at the end
	if clean_code:sub(-1) ~= char then
		local new_line = clean_code .. char
		
		-- Reassemble line with comment if exists
		if comment_part ~= "" then
			new_line = new_line .. " " .. comment_part
		end

		-- Update current line
		vim.api.nvim_set_current_line(new_line)
		
		-- Notify user
		print("Micro-plugin: Appended '" .. char .. "'")
	end

	-- Restore cursor position
	vim.api.nvim_win_set_cursor(0, cursor)
end

return M
