#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <iostream>

#include "flutter_window.h"
#include "utils.h"
#include <VersionHelpers.h>

#define SW_HIDE 0
#define SW_SHOW 5

// check if the application is running on Windows 11 or later
bool IsWindows11OrLater()
{
    OSVERSIONINFOEX osvi = {};
    osvi.dwOSVersionInfoSize = sizeof(OSVERSIONINFOEX);
    osvi.dwMajorVersion = 10;
    osvi.dwBuildNumber = 22000; // Windows 11 build number

    DWORDLONG dwlConditionMask = 0;
    dwlConditionMask = VerSetConditionMask(dwlConditionMask, VER_MAJORVERSION, VER_GREATER_EQUAL);
    dwlConditionMask = VerSetConditionMask(dwlConditionMask, VER_BUILDNUMBER, VER_GREATER_EQUAL);

    return VerifyVersionInfo(&osvi, VER_MAJORVERSION | VER_BUILDNUMBER, dwlConditionMask);
}

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
        // Check if the OS is Windows 11 or later
        if (!IsWindows11OrLater())
        {
            // Hide the console window on older versions of Windows
            HWND hWnd = GetConsoleWindow();
            ShowWindow(hWnd, SW_HIDE);
        }
        else
        {
            std::cout << "Running on Windows 11 or later. Not hiding console due to terminal changes." << std::endl;
        }
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
