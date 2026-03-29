<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthApiController extends Controller
{
    public function login(Request $request){
        $validator = Validator::make($request->all(),[
            'email' => 'required|email',
            'password' => 'required'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        if(!User::where('email', $request->email)->exists()){
            return response()->json(['message' => "Email anda tidak terdaftar di sistem", 'success' => false], 401);
        }

        if(Auth::attempt($request->only(['email','password']))){
            $data = [
                'name' => Auth::user()->name,
                'token' => Auth::user()->createToken('auth-token')->plainTextToken
            ];

            return response()->json(['message' => "Login berhasil", 'success' => true, 'data' => $data], 200);
        }else{
            return response()->json(['message' => "Password Anda salah", 'success' => false], 401);
        }
    }

    public function register(Request $request){
        $validator = Validator::make($request->all(),[
            'name' => 'required',
            'email' => 'required|email|unique:users',
            'password' => 'required',
            'bio' => 'nullable',
            'profile' => 'nullable|image|mimes:jpeg,jpg,png'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }
        
        if($request->hasFile('profile')){
            $profile = $request->file('profile');
            $nmprofile = "profile_" . time() . '.' . $profile->getClientOriginalExtension();
            $profilePath = $profile->storeAs('profiles',$nmprofile,'s3');
        }else{
            $profilePath = null;
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'bio' => $request->bio ?? null,
            'profile' => $profilePath
        ]);

        $data = [
            'name' => $user->name,
            'token' => $user->createToken('auth-token')->plainTextToken
        ];

        return response()->json(['message' => "Register berhasil", 'success' => true, 'data' => $data], 201);
    }

    public function logout(Request $request){
        $request->user()->tokens()->delete();
        return response()->json(['message' => "Anda telah logout", 'success' => true], 200);
    }
}
