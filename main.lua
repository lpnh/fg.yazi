local shell = os.getenv("SHELL"):match(".*/(.*)")

local bat_cmd = "bat --color=always --highlight-line={2} --line-range"
local bat_tbl = {
	default = [===[line={2} && begin=$(if [[ $line -lt 11 ]]; then echo $((line-1)); else echo 10; fi) && ]===]
		.. bat_cmd
		.. [===[ $((line-begin)):$((line+10)) {1}]===],
	fish = [[set line {2} && set begin (test $line -lt 11  &&  echo (math "$line-1") || echo  10) && ]]
		.. bat_cmd
		.. [[ (math "$line-$begin"):(math "$line+10") {1}]],
}
local bat_prev = bat_tbl[shell] or bat_tbl.default
local rg_cmd = "rg --color=always --line-number --smart-case"
local rga_cmd = "rga --color=always --files-with-matches --smart-case"
local rga_prev = "rga --context 5 --no-messages --pretty {q} {}"

local fzf_from = function(grep, prev)
	local fzf_tbl = {
		"fzf",
		"--ansi",
		"--delimiter=:",
		"--disabled",
		"--layout=reverse",
		"--no-multi",
		"--nth=3..",
		"--bind='start:reload:" .. grep .. " {q}'",
		"--bind='change:reload:sleep 0.1; " .. grep .. " {q} || true'",
		"--preview='" .. prev .. "'",
		"--preview-window=up,65%",
		"--bind='ctrl-w:change-preview-window(80%|65%)'",
		"--bind='ctrl-\\:change-preview-window(right|up)'",
	}

	return table.concat(fzf_tbl, " ")
end

local args_from = {
	rg = fzf_from(rg_cmd, bat_prev),
	rga = fzf_from(rga_cmd, rga_prev),
}

local fail = function(s, ...) ya.notify { title = "fg", content = string.format(s, ...), timeout = 5, level = "error" } end
local get_cwd = ya.sync(function() return cx.active.current.cwd end)

local function entry(_, job)
	local _permit = ya.hide()
	local args = args_from[job.args[1]]
	local cwd = tostring(get_cwd())

	local child, err = Command(shell)
		:args({ "-c", args })
		:cwd(cwd)
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return fail("Command failed with error code %s", err)
	end

	local output, err = child:wait_with_output()
	if not output then -- unreachable?
		return fail("Cannot read command output, error code %s", err)
	elseif output.status.code == 130 then -- interrupted with <ctrl-c> or <esc>
		return
	elseif output.status.code == 1 then -- no match
		return ya.notify { title = "fg", content = "No file selected", timeout = 5 }
	elseif output.status.code ~= 0 then -- anything other than normal exit
		return fail("`fzf` exited with error code %s", output.status.code)
	end

	local target = output.stdout:gsub("\n$", "")
	if target ~= "" then
		local colon_pos = string.find(target, ":")
		local file_url = colon_pos and string.sub(target, 1, colon_pos - 1) or target

		ya.manager_emit("reveal", { file_url })
	end
end

return { entry = entry }
