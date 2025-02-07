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
local rg_cmd = "rg --color=always --line-number --smart-case "
local rga_cmd = "rga --color=always --files-with-matches --smart-case "
local rga_prev = "rga --context 5 --no-messages --pretty {q} {}"

local rg_args = [[fzf --ansi --disabled --bind "start:reload:]]
	.. rg_cmd
	.. [[{q}" --bind "change:reload:sleep 0.1; ]]
	.. rg_cmd
	.. [[{q} || true" --delimiter : --preview ']]
	.. bat_prev
	.. [[' --preview-window 'up,60%' --nth '3..']]
local rga_args = [[fzf --ansi --disabled --layout=reverse --sort --header-first --header '---- Search inside files ----' --bind "start:reload:]]
	.. rga_cmd
	.. [[{q}" --bind "change:reload:sleep 0.1; ]]
	.. rga_cmd
	.. [[{q} || true" --delimiter : --preview ']]
	.. rga_prev
	.. [[' --preview-window 'up,60%' --nth '3..']]
local fg_args = [[rg --color=always --line-number --no-heading --smart-case '' | fzf --ansi --preview=']]
	.. bat_prev
	.. [[' --delimiter=':' --preview-window='up:60%' --nth='3..']]

local state = ya.sync(function() return cx.active.current.cwd end)

local function fail(s, ...) ya.notify { title = "fg", content = string.format(s, ...), timeout = 5, level = "error" } end

local function entry(_, job)
	local _permit = ya.hide()
	local cwd = tostring(state())
	local cmd_args = ""

	if job.args[1] == "rg" then
		cmd_args = rg_args
	elseif job.args[1] == "rga" then
		cmd_args = rga_args
	else
		cmd_args = fg_args
	end

	local child, err = Command(shell)
		:args({ "-c", cmd_args })
		:cwd(cwd)
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return fail("Command failed with error code %s.", err)
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
