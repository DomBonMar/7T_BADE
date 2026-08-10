function MASKS = get_masks(anatdir,type)

% retrieves subject's mask files in anat dir

    % matching layered masks
    if type == 'mask'
        mask_match = "*mask_layers.nii";
    % pattern used to match original masks (ends in mask.nii)
    elseif type == 'layers'
        mask_match = "*mask.nii";
    end

    % retrieving files
    cd(anatdir)
    MASKS = dir(mask_match);
    MASKS = string({MASKS.name});

end