#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <iostream>
#include <iomanip>

#include "flutter_window.h"
#include "utils.h"

bool isRunningFromCommandLine() {
    // if the process was attached to a console window at startup
    DWORD processList[2];
    if (GetConsoleProcessList(processList, 2) > 1) {
        // If more than one process is attached to the console, it's running from a command line
        return true;
    }
    return false;
}

int main(int argc, char** argv) {
    bool runningFromCommandLine = isRunningFromCommandLine();

    if (!runningFromCommandLine) {
        // If no console was attached (likely launched via GUI), create one
        if (AllocConsole()) {
            freopen_s(nullptr, "CONOUT$", "w", stdout);
            freopen_s(nullptr, "CONOUT$", "w", stderr);
        }
    }

    if (!runningFromCommandLine) {
        // Only show the formatted GUI-only output if the application was launched via GUI
        std::cerr << std::endl;
        std::cerr << " .-----------------. .----------------.  .----------------.  .----------------. " << std::endl;
        std::cerr << "| .--------------. || .--------------. || .--------------. || .--------------. |" << std::endl;
        std::cerr << "| | ____  _____  | || |      __      | || |  _________   | || |  _______     | |" << std::endl;
        std::cerr << "| ||_   \\|_   _| | || |     /  \\     | || | |_   ___  |  | || | |_   __ \\    | |" << std::endl;
        std::cerr << "| |  |   \\ | |   | || |    / /\\ \\    | || |   | |_  \\_|  | || |   | |__) |   | |" << std::endl;
        std::cerr << "| |  | |\\ \\| |   | || |   / ____ \\   | || |   |  _|  _   | || |   |  __ /    | |" << std::endl;
        std::cerr << "| | _| |_\\   |_  | || | _/ /    \\ \\_ | || |  _| |___/ |  | || |  _| |  \\ \\_  | |" << std::endl;
        std::cerr << "| ||_____\\____| | || ||____|  |____|| || | |_________|  | || | |____| |___| | |" << std::endl;
        std::cerr << "| |              | || |              | || |              | || |              | |" << std::endl;
        std::cerr << "| '--------------' || '--------------' || '--------------' || '--------------' |" << std::endl;
        std::cerr << " '----------------'  '----------------'  '----------------'  '----------------' " << std::endl;
        std::cerr << std::endl;
        std::cerr << "  Welcome to NAER Application" << std::endl;
        std::cerr << "  Version: 3.5.0" << std::endl;
        std::cerr << std::endl;
        std::cerr << " This is the command-line output window." << std::endl;
        std::cerr << " Did you know that you can use NAER as a console application too?" << std::endl;
        std::cerr << " Example input: " << std::endl;
        std::cerr << std::endl;
        std::cerr << "    NAER.exe D:\\SteamLibrary\\steamapps\\common\\NieRAutomata\\data \\" << std::endl;
        std::cerr << "             --output D:\\SteamLibrary\\steamapps\\common\\NieRAutomata\\data \\" << std::endl;
        std::cerr << "             ALL --enemies [em3000] --enemyStats 5.0 --level=99 \\" << std::endl;
        std::cerr << "             --p100 --category=allenemies --backUp" << std::endl;
        std::cerr << std::endl;
        std::cerr << "######### NAER GUI Application started successfully. ##########\n" << std::endl;
    }

    ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

    flutter::DartProject project(L"data");

    std::vector<std::string> command_line_arguments = GetCommandLineArguments();
    project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

    FlutterWindow window(project);
    Win32Window::Point origin(10, 10);
    Win32Window::Size size(1280, 720);
    if (!window.Create(L"NAER", origin, size)) {
        return EXIT_FAILURE;
    }
    window.SetQuitOnClose(true);

    ::MSG msg;
    while (::GetMessage(&msg, nullptr, 0, 0)) {
        ::TranslateMessage(&msg);
        ::DispatchMessage(&msg);
    }

    ::CoUninitialize();
    return EXIT_SUCCESS;
}
