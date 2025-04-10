/* Quartus Prime Version 21.1.0 Build 842 10/21/2021 Patches 0.02i SJ Lite Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Ign)
		Device PartName(SOCVHPS) MfrSpec(OpMask(0));
	P ActionCode(Cfg)
		Device PartName(5CSEMA4U23) Path("C:/Users/Parry/Documents/GitHub/ELEX-7660-PROJECT-V2/ELEX-7660-PROJECT/output_files/") File("lfoGenerator.sof") MfrSpec(OpMask(1));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
