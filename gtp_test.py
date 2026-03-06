from trex_stl_lib.api import *

class STLS1(object):

    def create_stream(self):

        pkt = Ether()/IP(dst="51.13.23.111")/UDP(dport=2152)/Raw("x"*1400)

        return STLStream(
            packet = STLPktBuilder(pkt = pkt),
            mode = STLTXCont(pps = 1000)
        )

    def get_streams(self, direction=0, **kwargs):
        return [self.create_stream()]

def register():
    return STLS1()