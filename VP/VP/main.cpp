#include <systemc>

#include "VP.hpp"
#include "def.hpp"

using namespace sc_core;
using namespace tlm;
using namespace std;

int sc_main(int argc, char* argv[])
{
	Vp vp("VP");
	sc_start(150, SC_NS);
	cout << "heeej" << endl;

	return 0;
}
