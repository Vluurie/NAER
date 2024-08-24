#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <iostream>

#include "flutter_window.h"
#include "utils.h"

bool isRunningFromCommandLine() {
    // Check if the process was attached to a console window at startup
    DWORD processList[2];
    if (GetConsoleProcessList(processList, 2) > 1) {
        return true; 
    }
    return false;
}

void DisableQuickEditMode() {
    // Get the console handle
    HANDLE hStdin = GetStdHandle(STD_INPUT_HANDLE);

    // Get the current console mode
    DWORD mode;
    GetConsoleMode(hStdin, &mode);

    // Clear the quick edit mode flag
    mode &= ~ENABLE_QUICK_EDIT_MODE;

    // Set the new mode
    SetConsoleMode(hStdin, mode);
}

void PrintWelcomeMessage() {
    std::cout << std::endl;
    std::cout << " .-----------------. .----------------.  .----------------.  .----------------. " << std::endl;
    std::cout << "| .--------------. || .--------------. || .--------------. || .--------------. |" << std::endl;
    std::cout << "| | ____  _____  | || |      __      | || |  _________   | || |  _______     | |" << std::endl;
    std::cout << "| ||_   \\|_   _| | || |     /  \\     | || | |_   ___  |  | || | |_   __ \\    | |" << std::endl;
    std::cout << "| |  |   \\ | |   | || |    / /\\ \\    | || |   | |_  \\_|  | || |   | |__) |   | |" << std::endl;
    std::cout << "| |  | |\\ \\| |   | || |   / ____ \\   | || |   |  _|  _   | || |   |  __ /    | |" << std::endl;
    std::cout << "| | _| |_\\   |_  | || | _/ /    \\ \\_ | || |  _| |___/ |  | || |  _| |  \\ \\_  | |" << std::endl;
    std::cout << "| ||_____\\____| | || ||____|  |____|| || | |_________|  | || | |____| |___| | |" << std::endl;
    std::cout << "| |              | || |              | || |              | || |              | |" << std::endl;
    std::cout << "| '--------------' || '--------------' || '--------------' || '--------------' |" << std::endl;
    std::cout << " '----------------'  '----------------'  '----------------'  '----------------' " << std::endl;
    std::cout << std::endl;
    std::cout << "  Welcome to NAER CLI Version" << std::endl;
    std::cout << "  Version: 3.6.0" << std::endl;
    std::cout << std::endl;
}

int main(int argc, char** argv) {
    bool runningFromCommandLine = isRunningFromCommandLine();

    if (runningFromCommandLine) {
        // If running from command line, print the welcome message
        PrintWelcomeMessage();
    } else {
        // If launched via GUI, hide the console
        HWND hWnd = GetConsoleWindow();
        ShowWindow(hWnd, SW_HIDE);
    }

    // Disable QuickEdit Mode to prevent accidental freezes
    DisableQuickEditMode();

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
