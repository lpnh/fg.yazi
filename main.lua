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

local rg_prefix = "rg --column --line-number --no-heading --color=always --smart-case "
local rga_prefix =
	"rga --files-with-matches --color ansi --smart-case --max-count=1 --no-messages --hidden --follow --no-ignore --glob '!.git' --glob !'.venv' --glob '!node_modules' --glob '!.history' --glob '!.Rproj.user' --glob '!.ipynb_checkpoints' "

local rg_args = [[fzf --ansi --disabled --bind "start:reload:]]
	.. rg_prefix
	.. [[{q}" --bind "change:reload:sleep 0.1; ]]
	.. rg_prefix
	.. [[{q} || true" --delimiter : --preview ']]
	.. bat_prev
	.. [[' --preview-window 'up,60%' --nth '3..']]
local rga_args = [[fzf --ansi --disabled --layout=reverse --sort --header-first --header '---- Search inside files ----' --bind "start:reload:]]
	.. rga_prefix
	.. [[{q}" --bind "change:reload:sleep 0.1; ]]
	.. rga_prefix
	.. [[{q} || true" --delimiter : --preview 'rga --smart-case --pretty --context 5 {q} {}' --preview-window 'up,60%' --nth '3..']]
local fg_args = [[rg --color=always --line-number --no-heading --smart-case '' | fzf --ansi --preview=']]
	.. bat_prev
	.. [[' --delimiter=':' --preview-window='up:60%' --nth='3..']]

local function split_and_get_first(input, sep)
	if sep == nil then
		sep = "%s"
	end
	local start, _ = string.find(input, sep)
	if start then
		return string.sub(input, 1, start - 1)
	end
	return input
end

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
		return fail("Spawn command failed with error code %s.", err)
	end

	local output, err = child:wait_with_output()
	if not output then
		return fail("Cannot read `fzf` output, error code %s", err)
	elseif not output.status.success and output.status.code ~= 130 then
		return fail("`fzf` exited with error code %s", output.status.code)
	end

	local target = output.stdout:gsub("\n$", "")

	local file_url = split_and_get_first(target, ":")

	if file_url ~= "" then
		ya.manager_emit(file_url:match("[/\\]$") and "cd" or "reveal", { file_url })
	end
end

return { entry = entry }
