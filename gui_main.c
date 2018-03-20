
#include <windows.h>
#include <scheme.h>

EXPORT int scheme_main(int, char **);

HINSTANCE hInstance;
HINSTANCE hPrevIntance; 

int WINAPI WinMain(HINSTANCE _hInstance, HINSTANCE _hPrevInstance, char **argv, int argc) {
	hInstance = _hInstance;
	hPrevIntance = _hPrevInstance;
	scheme_main(argc, argv);
}