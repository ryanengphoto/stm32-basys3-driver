#!/usr/bin/env python3
import os
import sys
import subprocess
import signal
import serial

class CLI:
    BANNER = r"""
    ┌─────────────────────────────────────────────┐
    │  Tiny interactive terminal-loop (Ctrl-C to  │
    │  exit)                                      │
    └─────────────────────────────────────────────┘
    Type 'help' for built-in commands.
    Run shell commands by prefixing with '!':  !echo hello
    """

    HELP = """Built-in commands:
    help | ?          show this help
    cls | clear     clear the screen
    exit | quit | q exit the program
    !<cmd>          run a shell command (e.g. !dir)
    Anything else gets echoed back.
    """
    # CLI COMMANDS
    HELP_CMDS = {"help", "?"}
    EXIT_CMDS = {"exit", "quit", "q"}
    CLEAR_CMDS = {"cls", "clear"}

    # ALU COMMANDS (unsigned for now)
    # addition, subtraction, increment, decrement
    ARITH_CMDS = {"add", "sub", "inc", "dec"} 
    # bitwise gates: &, |, ^, ~
    LOGIC_CMDS = {"and", "or", "xor", "not"}
    # left logical, arithmetic, right logical, arithmetic
    SHIFT_CMDS = {"sll", "sla", "srl", "sra"}
    # equal, greater than, less than 
    CMP_CMDS = {"eq", "slt", "sgt"}

    def __init__(self):
        self.clear_screen()
        self.clear_screen()
        print(self.BANNER)
        signal.signal(signal.SIGINT, self.sigint_handler)

    def connect_serial(self) -> None:
        stm32 = serial.Serial()
        pass

    def clear_screen(self) -> None:
        os.system('cls' if os.name == 'nt' else 'clear')

    def sigint_handler(self, signum, frame) -> None:
        print("\n^C detected — exiting.")
        sys.exit(0)

    def run_shell_command(self, cmd) -> None:
        try:
            subprocess.run(cmd, shell=True, check=False)
        except KeyboardInterrupt:
            print("\nCommand interrupted.")

    def run(self) -> None:
        while True:
            try:
                line = input("> ").strip()
            except EOFError:
                print("\nEOF received | exiting.")
                break
            except KeyboardInterrupt:
                print("\n^C received | exiting.")
                break

            if not line:
                continue

            split_line = line.split(' ', maxsplit=3)
            cmd = split_line[0]
            
            if cmd in (self.HELP_CMDS):
                print(self.HELP)
                continue

            if cmd in (self.EXIT_CMDS):
                print("Exiting.")
                break

            if cmd in (self.CLEAR_CMDS):
                self.clear_screen()
                continue

            if line.startswith("!"):
                self.run_shell_command(line[1:].strip())
                continue

            # ********************************
            # Arithmetic Commands
            # ********************************
            if (cmd in self.ARITH_CMDS):
                match cmd:
                    case "add":
                        if len(split_line) == 3:
                            try:
                                a = int(split_line[1])
                                b = int(split_line[2])
                                print(a + b)
                            except ValueError:
                                print("invalid operands, must be numbers")
                        else:
                            print("usage: add <num1> <num2>")

                    case "sub":
                        if len(split_line) == 3:
                            try:
                                a = int(split_line[1])
                                b = int(split_line[2])
                                print(a - b)
                            except ValueError:
                                print("invalid operands, must be numbers")
                        else:
                            print("usage: sub <num1> <num2>")
                        
                    case "inc":
                        if len(split_line) == 2:
                            try:
                                a = int(split_line[1])
                                print(a + 1)
                            except ValueError:
                                print("invalid operand, must be number")
                        else:
                            print("usage: inc <num>")
                        
                    case "dec":
                        if len(split_line) == 2:
                            try:
                                a = int(split_line[1])
                                print(a - 1)
                            except ValueError:
                                print("invalid operand, must be number")
                        else:
                            print("usage: dec <num>")
                
                continue

            # ********************************
            # Logical Commands
            # ********************************
            if (cmd in self.LOGIC_CMDS):
                match cmd:
                    case "and":
                        if len(split_line) == 3:
                            try:
                                a = int(split_line[1])
                                b = int(split_line[2])
                                print(a & b)
                            except ValueError:
                                print("invalid operands, must be numbers")
                        else:
                            print("usage: and <num1> <num2>")

                    case "or":
                        if len(split_line) == 3:
                            try:
                                a = int(split_line[1])
                                b = int(split_line[2])
                                print(a | b)
                            except ValueError:
                                print("invalid operands, must be numbers")
                        else:
                            print("usage: or <num1> <num2>")
                        
                    case "xor":
                        if len(split_line) == 3:
                            try:
                                a = int(split_line[1])
                                b = int(split_line[2])
                                print(a ^ b)
                            except ValueError:
                                print("invalid operands, must be numbers")
                        else:
                            print("usage: xor <num1> <num2>")
                        
                    case "not":
                        if len(split_line) == 2:
                            try:
                                a = int(split_line[1])
                                print(~a)
                            except ValueError:
                                print("invalid operand, must be number")
                        else:
                            print("usage: not <num>")
                
                continue

            # ********************************
            # Shift Commands
            # ********************************
            if (cmd in self.SHIFT_CMDS):

                continue


            # ********************************
            # Comparison Commands
            # ********************************
            if (cmd in self.CMP_CMDS):

                continue
            
            
                
            print(f"{cmd} is not a known command | enter \'help\' for valid commands.")

if __name__ == "__main__":
    cli = CLI()
    cli.run()