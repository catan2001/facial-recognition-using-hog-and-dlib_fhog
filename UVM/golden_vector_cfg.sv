`ifndef GOLDEN_VECTOR_CFG_SV
	`define GOLDEN_VECTOR_CFG_SV
	
	localparam DATAWIDTH = 16;

	typedef struct {
		int width = 0;
		int height = 0;
	} sizeOfFile_t; 

	class golden_vector_cfg extends uvm_object;

		static int widthInput = 0; // width of input picture
		static int heightInput = 0; // height of input picture
		static bit [DATAWIDTH - 1 : 0] dx_gv[$][$]; // dx golden vector queue 
		static bit [DATAWIDTH - 1 : 0] dy_gv[$][$]; // dy golden vector queue
		static bit [DATAWIDTH - 1 : 0] inputImg[$][$]; // input picture

		`uvm_object_utils(golden_vector_cfg)
		
		function new(string name = "golden_vector_cfg");
			super.new(name);
		endfunction 
		
		function void initializeData(string inputImgPath, string inputDxPath, string inputDyPath);
			readInputData(inputImgPath);
			readGoldenVectors(inputDxPath, inputDyPath);
		endfunction : initializeData

		function void readGoldenVectors(string inputDxPath, string inputDyPath);
			readData(inputDxPath, this.dx_gv);
			readData(inputDyPath, this.dy_gv);
		endfunction : readGoldenVectors

		function void readInputData(string inputImgPath);
			sizeOfFile_t inputFileSize = readData(inputImgPath, this.inputImg);
			this.widthInput = inputFileSize.width;
			this.heightInput = inputFileSize.height;
		endfunction : readInputData

		function sizeOfFile_t readData(string path, ref bit [DATAWIDTH - 1 : 0] data[$][$]);
			sizeOfFile_t fileSize = readFile(path, data);
			return fileSize;
		endfunction : readData

		function sizeOfFile_t readFile(string path, ref bit [DATAWIDTH - 1 : 0] imgQueue[$][$]);

			string row;
			string value;
			
			sizeOfFile_t fileSize;
			bit [DATAWIDTH - 1 : 0] imgRow[$];
			bit [DATAWIDTH - 1 : 0] bvalue;
			int widthCnt = 0;
			int heightCnt = 0;
			int lastIndex = 0;
			bit reachedEOF = 1;
			bit reachedEOL = 1;
			bit wordCheck = 1;

			int cnt;
			int fd = $fopen(path, "r");

			if (!fd) 
				uvm_report_fatal("GV_CFG_FATAL", $sformatf("Could not read: %0s", path));
			else begin
				uvm_report_info("GV_CFG_INFO", $sformatf("Successfully read: %0s", path), UVM_HIGH);
				while(reachedEOF) begin
					$fgets(row, fd);
					if(row == "")begin
						uvm_report_info("GV_CFG_INFO", "Reached End of line", UVM_DEBUG);
						reachedEOF = 0;
					end else 
					begin
						heightCnt++;
						widthCnt = 0;
						cnt = 0;
						value = "";
						reachedEOL = 1;
						wordCheck = 0;
						while(reachedEOL) begin
							if(row[cnt] == " " && value[0]!= " ") begin
								$sscanf(value, "%b", bvalue);
								
								imgRow.push_back(bvalue);
								value = "";
								wordCheck = 0;
								if(row[cnt + 1] == "\n") begin
									reachedEOL = 0;
								end
							end 
							else begin 
								value = {value, row[cnt]}; 
								if(!wordCheck) begin // found next value in row
									wordCheck = 1; // set 
									widthCnt++; // increment width
								end
							end
							
							if(row[cnt] != " " && cnt == row.len()) begin // in case end of line has no space
								$sscanf(value, "%b", bvalue);
								imgRow.push_back(bvalue);
								widthCnt++;
								reachedEOL = 0;
							end
							cnt++;

							if(cnt == row.len()) begin
								reachedEOL = 0;
							end
						end
						imgQueue.push_back(imgRow);
						imgRow.delete();
					end
				end 
				$fclose(fd);
			end

			fileSize.width = widthCnt;
			fileSize.height = heightCnt;
			return fileSize;
		endfunction : readFile

		function void deleteAll();
			delete2DArray(this.inputImg);
			delete2DArray(this.dx_gv);
			delete2DArray(this.dy_gv);
		endfunction : deleteAll

		function void delete2DArray(ref bit [DATAWIDTH - 1 : 0] array2D[$][$]);
			foreach(array2D[i]) begin
				array2D[i].delete();
			end
			array2D.delete();
		endfunction : delete2DArray
	
	endclass : golden_vector_cfg

`endif