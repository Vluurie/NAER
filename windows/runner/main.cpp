#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <iostream>

#include "flutter_window.h"
#include "utils.h"

bool isRunningFromCommandLine()
{
    // I check if the process was attached to a console window at startup
    DWORD processList[2];
    if (GetConsoleProcessList(processList, 2) > 1)
    {
        return true;
    }
    return false;
}

void DisableQuickEditMode()
{
    HANDLE hStdin = GetStdHandle(STD_INPUT_HANDLE);

    DWORD mode;
    GetConsoleMode(hStdin, &mode);

    mode &= ~ENABLE_QUICK_EDIT_MODE;
    SetConsoleMode(hStdin, mode);
}

void PrintWelcomeMessage()
{
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

int main(int argc, char **argv)
{
    bool runningFromCommandLine = isRunningFromCommandLine();

    if (runningFromCommandLine)
    {
        // If we are running from command line, i print the welcome message
        PrintWelcomeMessage();
    }
    else
    {
        // and if we are launched via GUI, i hide the console
        HWND hWnd = GetConsoleWindow();
        ShowWindow(hWnd, SW_HIDE);
    }

    // I disabled QuickEdit Mode to prevent accidental freezes
    DisableQuickEditMode();

    ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

    flutter::DartProject project(L"data");

    std::vector<std::string> command_line_arguments = GetCommandLineArguments();
    project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

    FlutterWindow window(project);
    Win32Window::Point origin(10, 10);
    Win32Window::Size size(1536, 864);
    if (!window.Create(L"NAER", origin, size))
    {
        return EXIT_FAILURE;
    }

    // I disabled resizing by removing the WS_THICKFRAME and WS_MAXIMIZEBOX styles
    HWND hwnd = window.GetHandle();
    LONG style = GetWindowLong(hwnd, GWL_STYLE);
    style &= ~(WS_THICKFRAME | WS_MAXIMIZEBOX);
    SetWindowLong(hwnd, GWL_STYLE, style);

    window.SetQuitOnClose(true);

    ::MSG msg;
    while (::GetMessage(&msg, nullptr, 0, 0))
    {
        ::TranslateMessage(&msg);
        ::DispatchMessage(&msg);
    }

    ::CoUninitialize();
    return EXIT_SUCCESS;
}
