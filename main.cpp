#include <iostream>
#include <fstream>
#include <vector>
using namespace std;

vector<string> getFileContent(string path),
	           split(string s, string delimiter);
void print(string s);
bool contains(string subject, string find),
	 isEmpty(string s);
string replace(string subject, const string& search, const string& replace = ""),
	   getSpaces(string s);

// could almost use parse seen last year but here we assume a well written code so we can restrict the syntax
int main()
{
	string fileName = "Share.ehru";
	vector<string> lines = getFileContent(fileName),
		           newLines;
	unsigned int linesSize = lines.size();
	for(unsigned int linesIndex = 0; linesIndex < linesSize; linesIndex++)
	{
		string line = lines[linesIndex];
		line = replace(line, "then");
		if(isEmpty(line))
		{
			continue;
		}
		else if(contains(line, "else if"))
		{
			vector<string> lineParts = split(line, "else if");
			newLines.push_back(lineParts[0] + "else");
			newLines.push_back(lineParts[0] + "\tif");
		}
		else
		{
			newLines.push_back(line);
		}
	}
	return 0;
}

string getSpaces(string s)
{
	string res = "";
	unsigned short sLen = s.length();
    for(unsigned short sIndex = 0; sIndex < sLen; sIndex++)
    {
        char c = s[sIndex];
        if(c != ' ')
            break;
		res += " ";
    }
    return res;
}

string replace(string subject, const string& search, const string& replace)
{
    unsigned int s = subject.find(search);
    if(s > subject.length())
        return subject;
    return subject.replace(s, search.length(), replace);
}

vector<string> split(string s, string delimiter)
{
    vector<string> toReturn;
    size_t pos = 0;
    while((pos = s.find(delimiter)) != string::npos)
    {
        toReturn.push_back(s.substr(0, pos));
        s.erase(0, pos + delimiter.length());
    }
    toReturn.push_back(s);
    return toReturn;
}

bool isEmpty(string s)
{
	unsigned short sLen = s.length();
	for(unsigned short sIndex = 0; sIndex < sLen; sIndex++)
	{
		char c = s[sIndex];
		if(c != ' ')
			return false;
	}
	return true;
}

bool contains(string subject, string find)
{
    return subject.find(find) != string::npos;
}

vector<string> getFileContent(string path)
{
	vector<string> vec;
	ifstream infile(path.c_str());
    string line;
    while(getline(infile, line))
        vec.push_back(line);
	return vec;
}

void print(string s)
{
	cout << s << endl;
}
