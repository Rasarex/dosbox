#include <iostream>
#include <map>
#include <stdint.h>
#include <fstream>
#include <vector>

struct note
{
    int8_t freql;
    int8_t freqh;
    int32_t duration;
};

std::map<char, std::array<uint32_t, 6>> notefreq;

int main()
{
    const int pause = 6;
    notefreq['c'] = std::array<uint32_t, 6>{33, 65, 131, 261, 523, 1047};
    notefreq['C'] = std::array<uint32_t, 6>{35, 69, 139, 277, 554, 1108};
    notefreq['d'] = std::array<uint32_t, 6>{37, 73, 147, 294, 587, 1175};
    notefreq['D'] = std::array<uint32_t, 6>{39, 78, 156, 311, 622, 1245};
    notefreq['E'] = std::array<uint32_t, 6>{41, 82, 165, 330, 659, 1319};
    notefreq['F'] = std::array<uint32_t, 6>{44, 87, 175, 349, 698, 1397};
    notefreq['G'] = std::array<uint32_t, 6>{49, 98, 196, 392, 784, 1568};
    notefreq['a'] = std::array<uint32_t, 6>{52, 104, 207, 415, 830, 1661};
    notefreq['A'] = std::array<uint32_t, 6>{55, 110, 220, 440, 880, 1760};
    notefreq['b'] = std::array<uint32_t, 6>{58, 116, 233, 466, 932, 1865};
    notefreq['H'] = std::array<uint32_t, 6>{62, 123, 247, 494, 988, 1976};
    notefreq['P'] = std::array<uint32_t, 6>{0, 0, 0, 0, 0, 0};

    std::ifstream ifile{"doom.hr", std::ios::in};
    std::ofstream ofile{"DOOM.IDI", std::ios::binary};
    while (ifile.good())
    {
        char note;
        int octave;
        uint16_t duration;
        ifile >> note;
        ifile >> octave;
        octave -= 1;
        ifile >> duration;
        uint32_t unote;
        try
        {
            notefreq.at(note);
        }
        catch (std::out_of_range &e)
        {
            std::cout << note << std::endl;
            exit(-1);
        }
        if (notefreq.at(note)[octave] != 0)
            unote = 1193180ul / notefreq.at(note)[octave];
        else
            unote = 0;
        uint8_t low = unote bitand 255;
        uint8_t high = notefreq[note][octave] >> 8 bitand 255;
        ofile << (unsigned char)low << high;
        duration *= 2;
        low = duration bitand 255;
        high = (duration >> 8) bitand 255;
        ofile << low << high;
        ofile << (char)0 << (char)0;
        low = 1;
        high = 0;
        ofile << low << high;
    }
    ofile << (char)0xFF << (char)0xFF;
}