#ifndef BRAM_HPP
#define BRAM_HPP

#include "systemc.h"
#include <tlm>
#include <tlm_utils/simple_target_socket.h>
#include <vector>
#include <iostream>
#include "def.hpp"

using namespace std;

class Bram : public sc_core::sc_module
{
public:
	Bram(sc_core::sc_module_name name);
	~Bram();
	tlm_utils::simple_target_socket<Bram> interconnect_socket;
protected:
	/*modeluje inicijatorsku komunikaciju fjom koja blokira dalje izvrsavanje procesa
	pl_t& je transakcija koja se salje; sc_time vrijeme koje transakcija treba da traje
	reference->znace da se parametri mogu mijenjati u toku fje*/
	void b_transport(pl_t&, sc_core::sc_time&); 
	vector<int> mem;
};

#endif // BRAM_HPP
