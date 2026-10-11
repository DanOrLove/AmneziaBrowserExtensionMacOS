package main

import (
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
)

func detachedProcessAttributes() *syscall.SysProcAttr {
	return &syscall.SysProcAttr{Setsid: true}
}

func processAlive(pid int) bool {
	if pid < 2 {
		return false
	}
	process, err := os.FindProcess(pid)
	if err != nil || process.Signal(syscall.Signal(0)) != nil {
		return false
	}

	commandLine, err := exec.Command("/bin/ps", "-p", strconv.Itoa(pid), "-o", "command=").Output()
	if err != nil {
		return false
	}
	executable, err := os.Executable()
	if err != nil {
		return false
	}
	dataDir, err := dataDirectory()
	if err != nil {
		return false
	}
	command := strings.TrimSpace(string(commandLine))
	return strings.Contains(command, filepath.Base(executable)+" proxy ") &&
		strings.Contains(command, filepath.Join(dataDir, "active.conf"))
}
