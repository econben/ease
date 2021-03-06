function crop_video(obj) 

tmp_folder_raw = fullfile(obj.data_folder, obj.raw_folder);
if ~exist(tmp_folder_raw, 'dir')
    mkdir(tmp_folder_raw);
elseif  length(dir(tmp_folder_raw))==(obj.num_scans*obj.num_slices+2)
    disp('the data has been cropped');
    return;
end

%% video shifts and FOV
shifts_video_ii = obj.video_shifts.ii;
shifts_video_jj = obj.video_shifts.jj;
if isempty(shifts_video_ii)
    error('the video data and the stack data has not been aligned yet\n'); 
end 
FOV_ = obj.FOV;

%% loading data
for mscan = 1:obj.num_scans
    for mblock = 1:obj.num_blocks
        tmp_scan = cell(1, obj.num_slices);
        tmp_file_raw = fullfile(tmp_folder_raw, sprintf('scan%d_block%d_complete.mat', mscan, mblock));
        if exist(tmp_file_raw, 'file')
            continue;
        end
        for mslice = 1:obj.num_slices
            % data loader
            dl_video = obj.video_loader{mscan, mslice, mblock};
            
            % shifts in x & y direction
            dy = round(shifts_video_ii(mscan, mslice));
            dx = round(shifts_video_jj(mscan, mslice));
            T = dl_video.num_frames;
            tmp_scan{mslice} = dl_video.load_tzrc([], [1,1], FOV_(1:2)+dy, FOV_(3:4)+dx);
        end
        [d1, d2, T] = size(tmp_scan{1});
        data = zeros(d1, d2, obj.num_slices, T, 'like', tmp_scan{1}(1));
        for mslice=1:obj.num_slices
            data(:, :, mslice, :) = tmp_scan{mslice};
        end
        
        save(tmp_file_raw, 'data', '-v7.3');
        disp([mscan, mblock]);
    end
end

